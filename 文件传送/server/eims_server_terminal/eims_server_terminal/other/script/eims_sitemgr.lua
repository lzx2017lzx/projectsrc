package.path = package.path ..";./?.lua;../other/script/?.lua;./script/?.lua"

require("eims_log")
require("eims_error")
require("eims_common")
require("eims_message")


-------------------------------------------------------
---
---	old: 0x17     修改网站的IP信息
---	new: 301
-------------------------------------------------------
eims_edit_site_ftp_info = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local domain = xml_opt:get_node_value(get_label_path("data", "domain"))
	local ftpip = xml_opt:get_node_value(get_label_path("data", "ftp_ip"))
	local ftpport = xml_opt:get_node_value(get_label_path("data", "ftp_port"))
	local ftpuser = xml_opt:get_node_value(get_label_path("data", "ftp_user"))
	local ftppwd = xml_opt:get_node_value(get_label_path("data", "ftp_pwd"))
	local ftppath = xml_opt:get_node_value(get_label_path("data", "ftp_path"))

	local sql = "select 1 from v_sites where (creater_id = "..eims_safety(userid).." or creater_soft_owner_id = "..eims_safety(userid)
	sql = sql.." or creater_soft_user_id = "..eims_safety(userid).." or creater_site_owner_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid)
	sql = sql.." or owner_soft_owner_id = "..eims_safety(userid).." or owner_soft_user_id = "..eims_safety(userid).." or owner_site_owner_id = "..eims_safety(userid)..") and `id` = "..eims_safety(siteid)

	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点不存在或没有权限")
	end
	mysql_opt:release_res()

	--local data_ver = tool:get_data_sequence()
	sql = "update t_sites set domain_name = '"..eims_safety(domain).."', ftp_ip = '"..eims_safety(ftpip).."', ftp_port = "..eims_safety(ftpport)
	sql = sql..", ftp_username = '"..eims_safety(ftpuser).."', ftp_password = '"..eims_safety(ftppwd).."', ftp_path = '"..eims_safety(ftppath)
	sql = sql.."' where `id` = "..eims_safety(siteid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "update t_site_user_id_list set data_version = now() where site_id = "..eims_safety(siteid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()

end


-------------------------------------------------------
---
---	old: 0x34    根据 site_id, 获取其所有的具有使用权的 user(对网站有管理权的用户才能操作)
---	new: 305
-------------------------------------------------------
eims_get_all_users_by_siteid = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))

	local sql = "select 1 from v_sites where (creater_id = "..eims_safety(userid).." or creater_soft_owner_id = "..eims_safety(userid)
	sql = sql.." or creater_soft_user_id = "..eims_safety(userid).." or creater_site_owner_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid)
	sql = sql.." or owner_soft_owner_id = "..eims_safety(userid).." or owner_soft_user_id = "..eims_safety(userid).." or owner_site_owner_id = "..eims_safety(userid)..") "
	sql = sql.." and `id` = "..eims_safety(siteid)

	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点不存在或没有权限")
	end
	mysql_opt:release_res()

	sql = "select t_users.* ,"
	sql = sql.." null as group_id, ('none') as group_name, t_site_user_id_list.is_allow_design, t_site_user_id_list.is_allow_edit_data "
	sql = sql.."from (t_site_user_id_list join t_users) where (t_site_user_id_list.site_id = "..eims_safety(siteid).." and t_site_user_id_list.user_id = t_users.`id` "
	sql = sql.."and t_site_user_id_list.group_id = -1) union select t_users.*, (select id from t_site_group where site_id = "..eims_safety(siteid)
	sql = sql.." and id = t_user_in_sitegroup.group_id) as group_id, (select name from t_site_group where site_id = "..eims_safety(siteid)
	sql = sql.." and id = t_user_in_sitegroup.group_id) as group_name, 1 is_allow_design, 1 is_allow_edit_data from "
	sql = sql.."(t_user_in_sitegroup join t_users) where (t_user_in_sitegroup.site_id = "..eims_safety(siteid).." and t_user_in_sitegroup.user_id = t_users.`id` "
	sql = sql.."and group_id in (select group_id from t_site_user_id_list where t_site_user_id_list.group_id = group_id))"

	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "未找到用户")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local user = get_label_path("user")
	local users = user.."s"
	xml_opt:add_child_node(users, "", data)
	for i = 0, row_count - 1 do
		local p = data.."/"..users.."/"..user..tostring(i)
		xml_opt:add_child_node(user..tostring(i), "", data.."/"..users)

		xml_opt:add_child_node(get_label_path("id"), 					mysql_opt:get_query_result(i, "id"), 				p)
		xml_opt:add_child_node(get_label_path("name"), 					mysql_opt:get_query_result(i, "name"), 				p)
		xml_opt:add_child_node(get_label_path("reality_name"), 			mysql_opt:get_query_result(i, "reality_name"), 		p)
		xml_opt:add_child_node(get_label_path("register_time"), 		mysql_opt:get_query_result(i, "register_time"), 	p)
		xml_opt:add_child_node(get_label_path("is_allow_login"), 		mysql_opt:get_query_byte_result(i, "is_allow_login"), 	p)
		xml_opt:add_child_node(get_label_path("login_count"), 			mysql_opt:get_query_result(i, "login_count"), 		p)
		xml_opt:add_child_node(get_label_path("last_login_time"), 		mysql_opt:get_query_result(i, "last_login_time"), 	p)
		xml_opt:add_child_node(get_label_path("last_login_ip"), 		mysql_opt:get_query_result(i, "last_login_ip"), 	p)
		xml_opt:add_child_node(get_label_path("is_online"), 			mysql_opt:get_query_byte_result(i, "is_online"), 	p)
		xml_opt:add_child_node(get_label_path("is_actived"), 			"1", 												p)
		xml_opt:add_child_node(get_label_path("default_identity"), 		mysql_opt:get_query_result(i, "default_identity"), 	p)
		xml_opt:add_child_node(get_label_path("soft_type"), 			mysql_opt:get_query_result(i, "soft_type"), 		p)
		xml_opt:add_child_node(get_label_path("soft_owner_id"), 		mysql_opt:get_query_result(i, "soft_owner_id"), 	p)
		xml_opt:add_child_node(get_label_path("soft_user_id"), 			mysql_opt:get_query_result(i, "soft_user_id"), 		p)
		xml_opt:add_child_node(get_label_path("site_owner_id"), 		mysql_opt:get_query_result(i, "site_owner_id"), 	p)
		xml_opt:add_child_node(get_label_path("company_name"), 			mysql_opt:get_query_result(i, "company_name"), 		p)
		xml_opt:add_child_node(get_label_path("email"), 				mysql_opt:get_query_result(i, "email"), 			p)
		xml_opt:add_child_node(get_label_path("telephone"), 			mysql_opt:get_query_result(i, "telephone"), 		p)
		xml_opt:add_child_node(get_label_path("mobile"), 				mysql_opt:get_query_result(i, "mobile"), 			p)
		xml_opt:add_child_node(get_label_path("id_card_number"), 		mysql_opt:get_query_result(i, "id_card_number"), 	p)
		xml_opt:add_child_node(get_label_path("address"), 				mysql_opt:get_query_result(i, "address"), 			p)
		xml_opt:add_child_node(get_label_path("postcode"), 				mysql_opt:get_query_result(i, "postcode"), 			p)
		xml_opt:add_child_node(get_label_path("is_allow_design"), 		mysql_opt:get_query_byte_result(i, "is_allow_design"), 	p)
		xml_opt:add_child_node(get_label_path("is_allow_edit"), 		mysql_opt:get_query_byte_result(i, "is_allow_edit_data"), p)
		xml_opt:add_child_node(get_label_path("group_id"), 				mysql_opt:get_query_result(i, "group_id"), 			p)
		xml_opt:add_child_node(get_label_path("group_name"), 			mysql_opt:get_query_result(i, "group_name"), 		p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: part of old edit siteinfo function
--	new: 310
---------------------------------------------
eims_edit_site_base_info = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local sitename = xml_opt:get_node_value(get_label_path("data", "name"))
	local sitealias = xml_opt:get_node_value(get_label_path("data", "site_alias"))
	local sitedesc = xml_opt:get_node_value(get_label_path("data", "desc"))
	local companyname = xml_opt:get_node_value(get_label_path("data", "company_name"))
	local tradetypeid = xml_opt:get_node_value(get_label_path("data", "trade_type_id"))
	local provinceid = xml_opt:get_node_value(get_label_path("data", "province_id"))
	local cityid = xml_opt:get_node_value(get_label_path("data", "city_id"))
	local areaid = xml_opt:get_node_value(get_label_path("data", "area_id"))

	local sql = "select 1 from v_sites where (creater_id = "..eims_safety(userid).." or creater_soft_owner_id = "..eims_safety(userid).." or creater_soft_user_id = "..eims_safety(userid)
		sql = sql.." or creater_site_owner_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid).." or owner_soft_owner_id = "..eims_safety(userid).." or owner_soft_user_id = "..eims_safety(userid)
		sql = sql.." or owner_site_owner_id = "..eims_safety(userid)..") and `id` = "..eims_safety(siteid)
	
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点不存在或没有权限")
	end
	mysql_opt:release_res()

	sql = "update t_sites set `site_alias` = '"..eims_safety(sitealias).."', `description` = '"..eims_safety(sitedesc).."', company_name = '"..companyname.."', trade_type_id = "..tradetypeid..", "
	sql = sql.."province_id = "..eims_safety(provinceid)..", city_id = "..eims_safety(cityid)..", area_id = "..eims_safety(areaid).." where `id` = "..eims_safety(siteid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	--local data_ver = tool:get_data_sequence()
	sql = "update t_site_user_id_list set data_version = now() where site_id = "..eims_safety(siteid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end	
	
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()

end

---------------------------------------------
--
--	old: 0x3C     重载编辑站点基本信息
--	new: 311
---------------------------------------------
eims_edit_site_version_info = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local ownerid = xml_opt:get_node_value(get_label_path("data", "owner_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local buildver = xml_opt:get_node_value(get_label_path("data", "builder_ver"))

	local sql = "select 1 from t_sites where `id` = "..eims_safety(siteid).." and owner_id = "..eims_safety(ownerid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点不存在或没有权限")
	end
	mysql_opt:release_res()

	--local data_ver = tool:get_data_sequence()
	sql = "update t_sites set builder_version = '"..eims_safety(buildver).."' where `id` = "..eims_safety(siteid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()

end

---------------------------------------------
--
--	old: 0x3D
--	new: 312
---------------------------------------------
eims_get_site_all_info = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	--print("site id is "..siteid)
	local sql = "select type, `status`, is_buy, open_time, expire_time, releaseIng_time, lang from t_site_expands where site_id = "..eims_safety(siteid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local sitetype = 0
	local record_count = mysql_opt:get_row_count()
	--int type = 0;       -- 1、pc 2、手机 3、微信 4、app
    -- status 状态(0 未发布  1 已发布 2 发布中)
    local subinfo = {}
    for i = 0, record_count - 1 do
    	local type = mysql_opt:get_query_result(i, "type")
    	subinfo[tostring(type)] = {status = mysql_opt:get_query_result(i, "status"),
    					isbuy = mysql_opt:get_query_result(i, "is_buy"), 
    					lang = mysql_opt:get_query_result(i, "lang"),
    					opentime = mysql_opt:get_query_result(i, "open_time"),
    					expiretime = mysql_opt:get_query_result(i, "expire_time"),
    					releasetime = mysql_opt:get_query_result(i, "releaseIng_time")}
    end
	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点扩展信息不存在")
	end
	mysql_opt:release_res()

	sql = "select * from t_sites where id = "..eims_safety(siteid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点不存在")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local site = get_label_path("site")
	xml_opt:add_child_node(site, "", data)	
	local p = data.."/"..site
	xml_opt:add_child_node(get_label_path("owner_id"), 			mysql_opt:get_query_result(0, "owner_id"), 			p)
	xml_opt:add_child_node(get_label_path("site_id"), 			mysql_opt:get_query_result(0, "id"), 				p)
	xml_opt:add_child_node(get_label_path("name"), 				mysql_opt:get_query_result(0, "name"), 				p)
	xml_opt:add_child_node(get_label_path("site_alias"), 		mysql_opt:get_query_result(0, "site_alias"), 		p)
	xml_opt:add_child_node(get_label_path("description"), 		mysql_opt:get_query_result(0, "description"), 		p)
	xml_opt:add_child_node(get_label_path("company_name"), 		mysql_opt:get_query_result(0, "company_name"), 		p)
	xml_opt:add_child_node(get_label_path("short_company_name"), mysql_opt:get_query_result(0, "short_company_name"), p)
	xml_opt:add_child_node(get_label_path("creater_id"), 		mysql_opt:get_query_result(0, "creater_id"), 		p)
	xml_opt:add_child_node(get_label_path("builder_version"), 	mysql_opt:get_query_result(0, "builder_version"), 	p)
	xml_opt:add_child_node(get_label_path("create_time"), 		mysql_opt:get_query_result(0, "create_time"), 		p)
	xml_opt:add_child_node(get_label_path("app_install_count"), "0", 												p)
	xml_opt:add_child_node(get_label_path("trade_type_id"), 	mysql_opt:get_query_result(0, "trade_type_id"), 	p)
	xml_opt:add_child_node(get_label_path("province_id"), 		mysql_opt:get_query_result(0, "province_id"), 		p)
	xml_opt:add_child_node(get_label_path("city_id"), 			mysql_opt:get_query_result(0, "city_id"), 			p)
	xml_opt:add_child_node(get_label_path("area_id"), 			mysql_opt:get_query_result(0, "area_id"), 			p)
	xml_opt:add_child_node(get_label_path("domain_name"), 		mysql_opt:get_query_result(0, "domain_name"), 		p)
	xml_opt:add_child_node(get_label_path("m_domain_name"), 	mysql_opt:get_query_result(0, "m_domain_name"), 	p)
	xml_opt:add_child_node(get_label_path("ftp_ip"), 			mysql_opt:get_query_result(0, "ftp_ip"), 			p)
	xml_opt:add_child_node(get_label_path("ftp_port"), 			mysql_opt:get_query_result(0, "ftp_port"), 			p)
	xml_opt:add_child_node(get_label_path("ftp_username"), 		mysql_opt:get_query_result(0, "ftp_username"), 		p)
	xml_opt:add_child_node(get_label_path("ftp_password"), 		mysql_opt:get_query_result(0, "ftp_password"), 		p)
	xml_opt:add_child_node(get_label_path("ftp_path"), 			mysql_opt:get_query_result(0, "ftp_path"), 			p)
	xml_opt:add_child_node(get_label_path("address"), 			mysql_opt:get_query_result(0, "address"), 			p)
	xml_opt:add_child_node(get_label_path("member_on"), 		mysql_opt:get_query_result(0, "member_on"), 		p)
	xml_opt:add_child_node(get_label_path("pc_on"), 			subinfo["1"].status, 								p)
	xml_opt:add_child_node(get_label_path("is_buy_pc"), 		subinfo["1"].isbuy, 								p)
	xml_opt:add_child_node(get_label_path("pc_language"), 		subinfo["1"].lang, 									p)
	xml_opt:add_child_node(get_label_path("open_time"), 		subinfo["1"].opentime, 								p)
	xml_opt:add_child_node(get_label_path("expire_time"), 		subinfo["1"].expiretime, 							p)
	xml_opt:add_child_node(get_label_path("releaseIng_time"), 	subinfo["1"].releasetime, 							p)
	xml_opt:add_child_node(get_label_path("m_on"), 				subinfo["2"].status, 								p)
	xml_opt:add_child_node(get_label_path("is_buy_m"), 			subinfo["2"].isbuy, 								p)
	xml_opt:add_child_node(get_label_path("m_language"), 		subinfo["2"].lang, 									p)
	xml_opt:add_child_node(get_label_path("m_open_time"), 		subinfo["2"].opentime, 								p)
	xml_opt:add_child_node(get_label_path("m_expire_time"), 	subinfo["2"].expiretime, 							p)
	xml_opt:add_child_node(get_label_path("m_releaseIng_time"), subinfo["2"].releasetime, 							p)
	xml_opt:add_child_node(get_label_path("wx_on"), 			subinfo["3"].status, 								p)
	xml_opt:add_child_node(get_label_path("is_buy_wx"), 		subinfo["3"].isbuy, 								p)
	xml_opt:add_child_node(get_label_path("wx_language"), 	subinfo["3"].lang, 									p)
	xml_opt:add_child_node(get_label_path("wx_open_time"), 		subinfo["3"].opentime, 								p)
	xml_opt:add_child_node(get_label_path("wx_expire_time"), 	subinfo["3"].expiretime, 							p)
	xml_opt:add_child_node(get_label_path("wx_releaseIng_time"), subinfo["3"].releasetime, 							p)
	xml_opt:add_child_node(get_label_path("app_on"), 			subinfo["4"].status, 								p)
	xml_opt:add_child_node(get_label_path("is_buy_app"), 		subinfo["4"].isbuy, 								p)
	xml_opt:add_child_node(get_label_path("app_language"), 		subinfo["4"].lang, 									p)
	xml_opt:add_child_node(get_label_path("app_open_time"), 	subinfo["4"].opentime, 								p)
	xml_opt:add_child_node(get_label_path("app_expire_time"), 	subinfo["4"].expiretime, 							p)
	xml_opt:add_child_node(get_label_path("app_releaseIng_time"), subinfo["4"].releasetime, 						p)
	xml_opt:add_child_node(get_label_path("source"), 			mysql_opt:get_query_result(0, "source"), 			p)
	xml_opt:add_child_node(get_label_path("is_preview"), 		mysql_opt:get_query_result(0, "is_preview"), 		p)
	xml_opt:add_child_node(get_label_path("telephone"), 		mysql_opt:get_query_result(0, "telephone"), 		p)
	xml_opt:add_child_node(get_label_path("fax"), 				mysql_opt:get_query_result(0, "fax"), 				p)
	xml_opt:add_child_node(get_label_path("postcode"), 			mysql_opt:get_query_result(0, "postcode"), 			p)
	xml_opt:add_child_node(get_label_path("icp_number"), 		mysql_opt:get_query_result(0, "icp_number"), 		p)
	xml_opt:add_child_node(get_label_path("manager_name"), 		mysql_opt:get_query_result(0, "manager_name"), 		p)
	xml_opt:add_child_node(get_label_path("manager_sex"), 		mysql_opt:get_query_result(0, "manager_sex"), 		p)
	xml_opt:add_child_node(get_label_path("manager_eims_id"), 	mysql_opt:get_query_result(0, "manager_eims_id"), 	p)
	xml_opt:add_child_node(get_label_path("manager_phone"), 	mysql_opt:get_query_result(0, "manager_phone"), 	p)
	xml_opt:add_child_node(get_label_path("manager_fax"), 		mysql_opt:get_query_result(0, "manager_fax"), 		p)
	xml_opt:add_child_node(get_label_path("manager_home_addr"), mysql_opt:get_query_result(0, "manager_home_address"), p)
	xml_opt:add_child_node(get_label_path("manager_email"), 	mysql_opt:get_query_result(0, "manager_email"), 	p)
	xml_opt:add_child_node(get_label_path("count_password"), 	mysql_opt:get_query_result(0, "count_password"), 	p)
	xml_opt:add_child_node(get_label_path("open_order"), 		mysql_opt:get_query_result(0, "is_open_order"), 	p)
	xml_opt:add_child_node(get_label_path("open_comment"), 		mysql_opt:get_query_result(0, "is_open_comment"), 	p)
	xml_opt:add_child_node(get_label_path("open_page_password"), mysql_opt:get_query_result(0, "is_open_page_password"), p)
	xml_opt:add_child_node(get_label_path("check_content"), 	mysql_opt:get_query_result(0, "is_check_content"), 	p)
	xml_opt:add_child_node(get_label_path("aspx_2_html"), 		mysql_opt:get_query_result(0, "is_aspx_to_html"), 	p)
	xml_opt:add_child_node(get_label_path("show_on_desk"), 		mysql_opt:get_query_result(0, "is_show_on_desk"), 	p)
	xml_opt:add_child_node(get_label_path("open_discount"), 	mysql_opt:get_query_result(0, "is_open_discount"), 	p)
	xml_opt:add_child_node(get_label_path("open_orderassistdetail"), mysql_opt:get_query_result(0, "is_open_orderassistdetail"), p)
	xml_opt:add_child_node(get_label_path("open_shop_card_manager"), mysql_opt:get_query_result(0, "is_open_shop_card_manager"), p)
	xml_opt:add_child_node(get_label_path("open_integral_set"), mysql_opt:get_query_result(0, "is_open_integral_set"), p)
	xml_opt:add_child_node(get_label_path("open_site_notify"), 	mysql_opt:get_query_result(0, "is_open_site_notify"), p)
	xml_opt:add_child_node(get_label_path("open_finance_manager"), mysql_opt:get_query_result(0, "is_open_finance_manager"), p)
	xml_opt:add_child_node(get_label_path("open_statistical_report"), mysql_opt:get_query_result(0, "is_open_statistical_report"), p)
	xml_opt:add_child_node(get_label_path("open_statistical_access_content"), mysql_opt:get_query_result(0, "is_open_statistical_access_content"), p)
	xml_opt:add_child_node(get_label_path("open_cps"), 			mysql_opt:get_query_result(0, "is_open_cps"), 		p)
	xml_opt:add_child_node(get_label_path("open_salestorage"), 	mysql_opt:get_query_result(0, "is_open_salestorage"), p)
	--local temp = mysql_opt:get_query_result(0, "is_open_usergrouplevel")
	--if temp == nil then
	--	print("temp is nil")
	--end
	xml_opt:add_child_node(get_label_path("open_usergrouplevel"), mysql_opt:get_query_result(0, "is_open_usergrouplevel"), p)
	xml_opt:add_child_node(get_label_path("open_department"), 	mysql_opt:get_query_result(0, "is_open_department"), p)
	xml_opt:add_child_node(get_label_path("open_advisory"), 	mysql_opt:get_query_result(0, "is_open_advisory"), 	p)
	xml_opt:add_child_node(get_label_path("open_cashcoupon"), 	mysql_opt:get_query_result(0, "is_open_cashcoupon"), p)
	xml_opt:add_child_node(get_label_path("open_giftcoupon"), 	mysql_opt:get_query_result(0, "is_open_giftcoupon"), p)
	xml_opt:add_child_node(get_label_path("open_instalment"), 	mysql_opt:get_query_result(0, "is_open_instalment"), p)
	xml_opt:add_child_node(get_label_path("open_pgdiscount"), 	mysql_opt:get_query_result(0, "is_open_pgdiscount"), p)
	xml_opt:add_child_node(get_label_path("open_messagenotify"), mysql_opt:get_query_result(0, "is_open_messagenotify"), p)
	mysql_opt:release_res()

	return xml_opt:create_xml_string()

end

---------------------------------------------
--
--	old: 0x3F
--	new: 314
---------------------------------------------
eims_update_website_info = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))

	local sql = "select id from v_sites where (creater_id = "..eims_safety(userid).." or creater_soft_owner_id = "..eims_safety(userid).." or creater_soft_user_id = "..eims_safety(userid)
	sql = sql.." or creater_site_owner_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid).." or owner_soft_owner_id = "..eims_safety(userid).." or owner_soft_user_id = "..eims_safety(userid)
	sql = sql.." or owner_site_owner_id = "..eims_safety(userid)..") and `id` = "..eims_safety(siteid)
	
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点不存在或没有权限")
	end
	
	local companyname = xml_opt:get_node_value(get_label_path("data", "company_name"))
	local telephone = xml_opt:get_node_value(get_label_path("data", "telephone"))
	local fax = xml_opt:get_node_value(get_label_path("data", "fax"))
	local postcode = xml_opt:get_node_value(get_label_path("data", "postcode"))
	local icp_num = xml_opt:get_node_value(get_label_path("data", "icp_num"))
	local managername = xml_opt:get_node_value(get_label_path("data", "manager_name"))
	local managergender = xml_opt:get_node_value(get_label_path("data", "manager_gender"))
	local manager_eims_id = xml_opt:get_node_value(get_label_path("data", "manager_eims_id"))
	local manager_mobile = xml_opt:get_node_value(get_label_path("data", "manager_mobile"))
	local manager_phone = xml_opt:get_node_value(get_label_path("data", "manager_phone"))
	local manager_fax = xml_opt:get_node_value(get_label_path("data", "manager_fax"))
	local manager_home_addr = xml_opt:get_node_value(get_label_path("data", "manager_home_addr"))
	local manager_email = xml_opt:get_node_value(get_label_path("data", "email"))
	mysql_opt:release_res()

	--local data_ver = tool.get_data_sequence()
	sql = "update t_sites set `company_name` = '"..eims_safety(companyname).."', `telephone` = '"..eims_safety(telephone).."', `fax` = '"..eims_safety(fax).."',"
	sql = sql.." postcode = '"..eims_safety(postcode).."', icp_number = '"..eims_safety(icp_num).."', manager_email = '"..eims_safety(manager_email).."',"
	sql = sql.." manager_name = '"..eims_safety(managername).."', manager_sex = "..eims_safety(managergender)..", manager_eims_id = "..eims_safety(manager_eims_id)..","
	sql = sql.." manager_mobile = '"..eims_safety(manager_mobile).."', manager_phone = '"..eims_safety(manager_phone).."', manager_post_code = '"..eims_safety(postcode).."',"
	sql = sql.." manager_fax = '"..eims_safety(manager_fax).."', manager_home_address = '"..eims_safety(manager_home_addr).."' where `id` = "..eims_safety(siteid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "update t_site_user_id_list set data_version = now() where site_id = "..eims_safety(siteid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")

	return xml_opt:create_xml_string()

end

---------------------------------------------
--
--	old: 0x67      通过网站ID或组ID，获取组的成员信息 (get_data_type = 0 通过网站ID获取组成员信息)    (get_data_type= 1 通过组ID获取成员信息)
--	new: 315
---------------------------------------------
eims_get_groupmember_by_group_or_site_id  = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local cid = xml_opt:get_node_value(get_label_path("data", "c_id"))
	local dtype = xml_opt:get_node_value(get_label_path("data", "d_type"))

	local sql = "select t1.id, t1.name, t1.login_count, t1.last_login_time, t2.group_id, t2.group_name, t2.create_date, t2.optioner_id "
	sql = sql.."from t_users t1 RIGHT JOIN (select user_id, create_date, optioner_id, group_id, (select name from t_site_group "
	sql = sql.."where id = group_id) group_name from t_user_in_sitegroup where "
	
	if dtype == "0" then
		sql = sql.."site_id = "..eims_safety(cid)
	else
		sql = sql.."group_id = "..eims_safety(cid)
	end
	sql = sql..") t2 on t1.id = t2.user_id"

	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local user_count = mysql_opt:get_row_count()
	if user_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "权限组不存在")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local user = get_label_path("user")
	local users = user.."s"
	xml_opt:add_child_node(users, "", data)
	for i = 0, user_count - 1 do
		xml_opt:add_child_node(user..tostring(i), "", data.."/"..users)
		local ctx = data.."/"..users.."/"..user..tostring(i)
		xml_opt:add_child_node(get_label_path("id"), mysql_opt:get_query_result(i, "id"), ctx)
		xml_opt:add_child_node(get_label_path("name"), mysql_opt:get_query_result(i, "name"), ctx)
		xml_opt:add_child_node(get_label_path("create_date"), mysql_opt:get_query_result(i, "create_date"), ctx)
		xml_opt:add_child_node(get_label_path("group_id"), mysql_opt:get_query_result(i, "group_id"), ctx)
		xml_opt:add_child_node(get_label_path("group_name"), mysql_opt:get_query_result(i, "group_name"), ctx)
		xml_opt:add_child_node(get_label_path("login_count"), mysql_opt:get_query_result(i, "login_count"), ctx)
		xml_opt:add_child_node(get_label_path("last_login_time"), mysql_opt:get_query_result(i, "last_login_time"), ctx)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()

end


---------------------------------------------
--
--	old: 0x59    通过用户ID和应用ID 判断该用户是否拥有该应用的权限
--	new: 316
---------------------------------------------
eims_check_is_site_user = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))

	local sql = "select 1 from t_site_user_id_list where `user_id` = "..userid.." and site_id = "..eims_safety(siteid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local row_count = mysql_opt:get_row_count()
	mysql_opt:release_res()

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	
	if row_count <= 0 then
		xml_opt:add_child_node(get_label_path("result"), "0", get_label_path("data"))
	else
		xml_opt:add_child_node(get_label_path("result"), "1", get_label_path("data"))
	end

	return xml_opt:create_xml_string()
end

eims_get_site_default_resource = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local empty = ""
	local sql = "select `name`, page_id, head_resource_id as head, navigate_resource_id as navigate, "
          sql = sql..empty.."banner_resource_id as banner, content_resource_id as content, "
          sql = sql..empty.."bottom_resource_id as bottom, marketing_resource_id as marketing, "
          sql = sql..empty.."background_resource_id as background, concat('"
          sql = sql..config.xny_res_url.."/heads/',head_resource_id,'.zip') as head_url, concat('"
          sql = sql..config.xny_res_url.."/navigates/',navigate_resource_id,'.zip') as navigate_url, concat('"
          sql = sql..config.xny_res_url.."/banners/',banner_resource_id,'.zip') as banner_url, concat('"
          sql = sql..config.xny_res_url.."/contents/', content_resource_id, '.zip') as content_url, concat('"
          sql = sql..config.xny_res_url.."/bottoms/', bottom_resource_id, '.zip') as bottom_url, concat('"
          sql = sql..config.xny_res_url.."/marketings/', marketing_resource_id, '.zip') as marketing_url, concat('"
          sql = sql..config.xny_res_url.."/backgrounds/', background_resource_id, '.zip') as background_url from t_std_site_pages where type = 1 and is_deleted = 0 and std_site_id = "..eims_safety(siteid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点不存在")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")

	local dl = get_label_path("data")
	local page = get_label_path("page")
	local pages = page.."s"
	xml_opt:add_child_node(pages, "", dl)
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(page..tostring(i), "", dl.."/"..pages)
		local p = dl.."/"..pages.."/"..page..tostring(i)
		xml_opt:add_child_node(get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
		xml_opt:add_child_node(get_label_path("page_id"), mysql_opt:get_query_result(i, "page_id"), p)
		xml_opt:add_child_node(get_label_path("head"), mysql_opt:get_query_result(i, "head"), p)
		xml_opt:add_child_node(get_label_path("head_url"), mysql_opt:get_query_result(i, "head_url"), p)
		xml_opt:add_child_node(get_label_path("navigate"), mysql_opt:get_query_result(i, "navigate"), p)
		xml_opt:add_child_node(get_label_path("navigate_url"), mysql_opt:get_query_result(i, "navigate_url"), p)
		xml_opt:add_child_node(get_label_path("banner"), mysql_opt:get_query_result(i, "banner"), p)
		xml_opt:add_child_node(get_label_path("banner_url"), mysql_opt:get_query_result(i, "banner_url"), p)
		xml_opt:add_child_node(get_label_path("content"), mysql_opt:get_query_result(i, "content"), p)
		xml_opt:add_child_node(get_label_path("content_url"), mysql_opt:get_query_result(i, "content_url"), p)
		xml_opt:add_child_node(get_label_path("bottom"), mysql_opt:get_query_result(i, "bottom"), p)
		xml_opt:add_child_node(get_label_path("bottom_url"), mysql_opt:get_query_result(i, "bottom_url"), p)
		xml_opt:add_child_node(get_label_path("marketing"), mysql_opt:get_query_result(i, "marketing"), p)
		xml_opt:add_child_node(get_label_path("marketing_url"), mysql_opt:get_query_result(i, "marketing_url"), p)
		xml_opt:add_child_node(get_label_path("background"), mysql_opt:get_query_result(i, "background"), p)
		xml_opt:add_child_node(get_label_path("background_url"), mysql_opt:get_query_result(i, "background_url"), p)
	end
	mysql_opt:release_res()

	sql = "select style, javascript from t_std_creatives where id = (select creative_id from t_std_step where site_id = "..eims_safety(siteid)..")"
	result = mysql:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "未找到风格创意编号")
	end

	xml_opt:add_child_node(get_label_path("creatives"), "", get_label_path("data"))
	xml_opt:add_child_node(get_label_path("bottom"), mysql_opt:get_query_result(0, "bottom"), get_label_path("data", "style"))
	xml_opt:add_child_node(get_label_path("javascript"), mysql_opt:get_query_result(0, "javascript"), get_label_path("data", "javascript"))

	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x3A    申请开通手机网站
--	new: 324
---------------------------------------------
eims_apply_mobile_site  = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local ownerid = xml_opt:get_node_value(get_label_path("data", "site_owner_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local m_domain = xml_opt:get_node_value(get_label_path("data", "m_domain"))
	local m_style_range = xml_opt:get_node_value(get_label_path("data", "m_style_range"))
	local years = xml_opt:get_node_value(get_label_path("data", "years"))

	local sql = "select id, m_state from t_sites where `id` = "..eims_safety(siteid).." and owner_id = "..eims_safety(ownerid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点不存在或没有权限")
	end
	local isopen = mysql_opt:get_query_result(0, "m_state")
	if isopen == "1" then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "该站点已经开通了手机网站")
	end
	mysql_opt:release_res()

	sql = "update t_sites set m_state = 2, m_domain_name = '"..eims_safety(m_domain).."', m_style_range = "..eims_safety(m_style_range)
	sql = sql.." where `id` = "..eims_safety(siteid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "insert into t_try_mobilesites (site_id, user_id, try_time, m_domain_name, m_style_range, years) "
	sql = sql.."values ("..eims_safety(siteid)..", "..eims_safety(ownerid)..", now(), '"..eims_safety(m_domain).."', '"..eims_safety(m_style_range).."', "..eims_safety(years)..")"
	result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x3B    打开关闭手机网站
--	new: 325
---------------------------------------------
eims_open_close_mobile_site = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local ownerid = xml_opt:get_node_value(get_label_path("data", "site_owner_id") )
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local m_on = xml_opt:get_node_value(get_label_path("data", "m_on"))
	local m_style = xml_opt:get_node_value(get_label_path("data", "m_style"))

	local sql = "select `id` from t_sites where `id` = "..eims_safety(siteid).." and owner_id = "..eims_safety(ownerid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点不存在或没有权限")
	end
	mysql_opt:release_res()

	sql = "update t_site_expands set status = "..eims_safety(m_on).." where `site_id` = "..eims_safety(siteid).." and `type` = 2"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败") 
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()

end


---------------------------------------------
--
--	old: 0x27      设置网站服务
--	new: 326
---------------------------------------------
eims_set_web_services = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local ownerid = xml_opt:get_node_value(get_label_path("data", "site_owner_id") )
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))

	local sql = "select 1 from t_sites where `id` = "..eims_safety(siteid).." and owner_id = "..eims_safety(ownerid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败") 
	end

	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点不存在或没有权限")
	end
	mysql_opt:release_res()

	local memberopen = xml_opt:get_node_value(get_label_path("data", "member_open"))
	local orderopen = xml_opt:get_node_value(get_label_path("data", "order_open"))
	local commentopen = xml_opt:get_node_value(get_label_path("data", "comment_open"))
	local pagepwdopen = xml_opt:get_node_value(get_label_path("data", "page_pwd_open"))
	local checkcontent = xml_opt:get_node_value(get_label_path("data", "check_content"))
	local aspxtohtml = xml_opt:get_node_value(get_label_path("data", "aspx_to_html"))
	local discountopen = xml_opt:get_node_value(get_label_path("data", "discount_open"))
	local orderdetail = xml_opt:get_node_value(get_label_path("data", "orderassistdetail_open"))
	local shopcardmgropen = xml_opt:get_node_value(get_label_path("data", "shop_card_mrg_open"))
	local integralopen = xml_opt:get_node_value(get_label_path("data", "integral_set_open"))
	local sitenotifyopen = xml_opt:get_node_value(get_label_path("data", "site_notify_open"))
	local financemgropen = xml_opt:get_node_value(get_label_path("data", "finance_mrg_open"))
	local statisticalreportopen = xml_opt:get_node_value(get_label_path("data", "statistical_report_open"))
	local statisticalaccesscontentopen = xml_opt:get_node_value(get_label_path("data", "statistical_access_content_open"))
	local cpsopen = xml_opt:get_node_value(get_label_path("data", "cps_open"))
	local salestorageopen = xml_opt:get_node_value(get_label_path("data", "salestorage_open"))
	local usergrouplevelopen = xml_opt:get_node_value(get_label_path("data", "usergrouplevel_open"))
	local departmentopen = xml_opt:get_node_value(get_label_path("data", "department_open"))
	local advisoryopen = xml_opt:get_node_value(get_label_path("data", "advisory_open"))
	local cashcouponopen = xml_opt:get_node_value(get_label_path("data", "cashcoupon_open"))
	local giftcouponopen = xml_opt:get_node_value(get_label_path("data", "giftcoupon_open"))
	local instalmentopen = xml_opt:get_node_value(get_label_path("data", "instalment_open"))
	local pgdiscountopen = xml_opt:get_node_value(get_label_path("data", "pgdiscount_open"))
	local messageopen = xml_opt:get_node_value(get_label_path("data", "message_open"))

	sql = "update t_sites set member_on = "..eims_safety(memberopen)..", is_open_order = "..eims_safety(orderopen)..", is_open_comment = "..eims_safety(commentopen)..", is_open_page_password = "..eims_safety(pagepwdopen)
	sql = sql..", is_check_content= (case when "..eims_safety(checkcontent).." = -1 then is_check_content else "..eims_safety(checkcontent).." end), is_aspx_to_html = (case when "..eims_safety(checkcontent).." = -1 "
	sql = sql.."then is_aspx_to_html else "..eims_safety(checkcontent).." end), is_open_discount = "..eims_safety(discountopen)..", "
    sql = sql.."is_open_orderassistdetail = "..eims_safety(orderdetail)..", is_open_shop_card_manager = "..eims_safety(shopcardmgropen)..", is_open_integral_set = "..eims_safety(integralopen)..", "
    sql = sql.."is_open_site_notify = "..eims_safety(sitenotifyopen)..", is_open_finance_manager = "..eims_safety(financemgropen)..", is_open_statistical_report = "..eims_safety(statisticalreportopen)..", "
    sql = sql.."is_open_statistical_access_content = "..eims_safety(statisticalaccesscontentopen)..", is_open_cps = "..eims_safety(cpsopen)..", is_open_salestorage = "..eims_safety(salestorageopen)..", "
    sql = sql.."is_open_usergrouplevel = "..eims_safety(usergrouplevelopen)..", is_open_department = "..eims_safety(departmentopen)..", is_open_advisory = "..eims_safety(advisoryopen)..", is_open_cashcoupon = "..eims_safety(cashcouponopen)..", "
    sql = sql.."is_open_giftcoupon = "..eims_safety(giftcouponopen)..", is_open_instalment = "..eims_safety(instalmentopen)..", is_open_pgdiscount = "..eims_safety(pgdiscountopen)..", "
    sql = sql.."is_open_messagenotify = "..eims_safety(messageopen).." where `id` = "..eims_safety(siteid)
    
    result = mysql_opt:oper_db(sql)
    if result ~= 0 then
    	logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败") 
    end

    xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()

end

---------------------------------------------
--
--	old: 0x30    根据 user_id, 创建网站, 创建者即为所有者
--	new: 327
---------------------------------------------
eims_create_site = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local name = xml_opt:get_node_value(get_label_path("data", "name"))
	local sitealias = xml_opt:get_node_value(get_label_path("data", "site_alias"))
	local desc = xml_opt:get_node_value(get_label_path("data", "desc"))
	local guid = xml_opt:get_node_value(get_label_path("data", "guid"))
	local companyname = xml_opt:get_node_value(get_label_path("data", "company_name"))
	local tradetypeid = xml_opt:get_node_value(get_label_path("data", "trade_type_id"))
	local provinceid = xml_opt:get_node_value(get_label_path("data", "province_id"))
	local cityid = xml_opt:get_node_value(get_label_path("data", "city_id"))
	local areaid = xml_opt:get_node_value(get_label_path("data", "area_id"))
	local domain = xml_opt:get_node_value(get_label_path("data", "domain"))
	local ftpip = xml_opt:get_node_value(get_label_path("data", "ftp_ip"))
	local ftpport = xml_opt:get_node_value(get_label_path("data", "ftp_port"))
	local ftpuser = xml_opt:get_node_value(get_label_path("data", "ftp_user"))
	local ftppwd = xml_opt:get_node_value(get_label_path("data", "ftp_pwd"))
	local ftppath = xml_opt:get_node_value(get_label_path("data", "ftp_path"))
	local appid = xml_opt:get_node_value(get_label_path("data", "app_id"))
	local mdomain = xml_opt:get_node_value(get_label_path("data", "m_domain"))
	local src = xml_opt:get_node_value(get_label_path("data", "src")) -- 站点来源 0: EIMS 云网站、1: 犀牛云网站、2: EIMS 板块云网站

	local sql = "select 1"
	if tonumber(appid) > 1 then
		--check is application already install
		sql = "select id from t_sites where owner_id = "..eims_safety(userid).." and application_id = "..eims_safety(appid).." and is_deleted = 0 and status = 0"
		local result = mysql_opt:oper_db(sql)
		if result ~= 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败") 
		end
		local row_count = mysql_opt:get_row_count()
		if row_count > 0 then
			mysql_opt:release_res()
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "该应用已经安装")
		end

		--check application is exist
		sql = "select id from t_applications where id = "..eims_safety(appid)
		local result = mysql_opt:oper_db(sql)
		if result ~= 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败") 
		end
		local row_count = mysql_opt:get_row_count()
		if row_count <= 0 then
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "该应用不存在")
		end
		mysql_opt:release_res()
	end

	sql = "select id from t_applications where id = "..eims_safety(appid).." and is_auto_install = 1"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败") 
	end

	local auto_inatall = false
	row_count = mysql_opt:get_row_count()
	mysql_opt:release_res()

	if row_count > 0 then
		auto_inatall = true
	end

	sql = "select default_identity from t_users where `id` = "..eims_safety(userid).." or `mobile` = "..eims_safety(userid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end
	mysql_opt:release_res()

	if tonumber(appid) > 1 then
		sql = "select id, `status` from t_sites where application_id = "..eims_safety(appid).." and creater_id = "..eims_safety(userid).." order by id desc limit 0, 1"
		result = mysql_opt:oper_db(sql)
		if result ~= 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
		row_count = mysql_opt:get_row_count()
		if row_count > 0 then
			local tempsiteid = mysql_opt:get_query_result(0, "id")
			local status = mysql_opt:get_query_result(0, "status")
			mysql_opt:release_res()

			if tonumber(status) == 1 or tonumber(status) == 2 then
				sql = "update t_sites set `status` = 0 where id = "..tempsiteid
				result = mysql_opt:oper_db(sql)
				if result ~= 0  then
					logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
					return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
				end
				xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
				return xml_opt:create_xml_string()
			end
		end
	end

	local countpassword = tool:get_rand_num(6)
	sql = "insert into t_sites (name, site_alias, description, guid, create_time, company_name, trade_type_id, province_id, city_id,"
	sql = sql.." area_id, domain_name, ftp_ip, ftp_port, ftp_username, ftp_password, ftp_path, creater_id, owner_id, application_id,"
	sql = sql.."count_password, source) values ('"..eims_safety(name).."', '"..eims_safety(sitealias).."', '"..eims_safety(desc).."', '"..eims_safety(guid).."', now(), '"..eims_safety(companyname).."', "
	sql = sql..eims_safety(tradetypeid)..","..eims_safety(provinceid)..","..eims_safety(cityid)..", "..eims_safety(areaid)..",'"..eims_safety(domain).."', '"..eims_safety(ftpip).."', "..eims_safety(ftpport)..", '"..eims_safety(ftpuser).."', '"
	sql = sql..eims_safety(ftppwd).."', '"..eims_safety(ftppath).."', "..eims_safety(userid)..", "..eims_safety(userid)..", "..eims_safety(appid)..", '"..countpassword.."',"..eims_safety(src)..")"
	
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local new_insert_id = result
	if auto_inatall then
		sql = "insert into t_site_user_id_list (site_id, user_id, is_allow_design, is_allow_edit_data, group_id) values "
		sql = sql.."("..tostring(new_insert_id)..", "..eims_safety(userid)..", 1, 1, -3)"
		result = mysql_opt:oper_db_trans_exc_v2(sql, false)
		if result < 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
	end
	
	if tonumber(appid) > 1 then
		sql = "update t_applications set `all_user_count` = (ifnull(`all_user_count`, 0) + 1),`install_count` = (ifnull(`install_count`, 0) + 1) where `id` = "..eims_safety(appid)
		result = mysql_opt:oper_db_trans_exc_v2(sql, true)
		if result < 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
	else
		sql = "insert into t_site_expands (site_id, type) values ("..eims_safety(siteid)..", 1)"
		result = mysql_opt:oper_db_trans_exc_v2(sql, false)
		if result < 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end

		sql = "insert into t_site_expands (site_id, type) values ("..eims_safety(siteid)..", 2)"
		result = mysql_opt:oper_db_trans_exc_v2(sql, false)
		if result < 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end

		sql = "insert into t_site_expands (site_id, type) values ("..eims_safety(siteid)..", 3)"
		result = mysql_opt:oper_db_trans_exc_v2(sql, false)
		if result < 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end

		sql = "insert into t_site_expands (site_id, type) values ("..eims_safety(siteid)..", 4)"
		result = mysql_opt:oper_db_trans_exc_v2(sql, false)
		if result < 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
		if mdomain ~= "" then
			sql = "update t_sites set m_domain_name = "..eims_safety(mdomain).." where site_id = "..eims_safety(siteid)
			result = mysql_opt:oper_db_trans_exc_v2(sql, true)
			if result < 0 then
				logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
				return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
			end
		end
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	xml_opt:add_child_node(get_label_path("site_id"), tostring(new_insert_id), "data")

	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x39    删除站点
--	new: 309
---------------------------------------------
eims_delete_site = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "soft_owner_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))

	local sql = "select id from t_sites where id = "..eims_safety(siteid).." and application_id > 0"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local instance_count = mysql_opt:get_row_count()
	mysql_opt:release_res()

	sql = "select id from v_sites where owner_id = "..eims_safety(userid).." and `id` = "..eims_safety(siteid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local owner_count = mysql_opt:get_row_count()
	mysql_opt:release_res()

	local delete_site_sql = ""
	if owner_count > 0 then
		sql = "update t_sites set is_deleted = 1, delete_time = now(), delete_user_id = "..eims_safety(userid).." where `id` = "..eims_safety(siteid)
		local result = mysql_opt:oper_db_trans_exc_v2(sql, false)
		if result ~= 0 then
			mysql_opt:rollback()
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
	
		delete_site_sql = "delete from t_site_user_id_list where site_id = "..eims_safety(siteid)
	else
		if instance_count > 0 then
			result = mysql_opt:oper_db_trans_exc_v2(sql, false)
			if result ~= 0 then
				mysql_opt:rollback()
				logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
				return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
			end

			delete_site_sql = "delete from t_site_user_id_list where site_id = "..eims_safety(siteid).." and user_id = "..eims_safety(userid)
		end
	end

	result = mysql_opt:oper_db_trans_exc_v2(delete_site_sql, true)
	if result ~= 0 then
		mysql_opt:rollback()
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..delete_site_sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")

	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x35    转让网站所有者, 具有网站管理权限的用户, 将站点的所有者转移给其他任意用户(如果其他用户是站点使用者身份, 则升级他的身份)
--	new: 306
---------------------------------------------
eims_change_site_owner = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local o_ownerid = xml_opt:get_node_value(get_label_path("data", "old_owner_id"))
	local n_ownerid = xml_opt:get_node_value(get_label_path("data", "new_owner_id"))
	local sql = "select `owner_id` from v_sites where (creater_id = "..eims_safety(userid).." or creater_soft_owner_id = "..eims_safety(userid).." or creater_soft_user_id = "..eims_safety(userid)
		  sql = sql.." or creater_site_owner_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid).." or owner_soft_owner_id = "..eims_safety(userid).." or owner_soft_user_id = "..eims_safety(userid)
		  sql = sql.." or owner_site_owner_id = "..eims_safety(userid)..") and `id` = "..eims_safety(siteid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "站点不存在或没有权限") 
	end

	local old_owner_id_db = mysql_opt:get_query_result(0, "owner_id")
	if old_owner_id_db ~= o_ownerid then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "原拥有者不匹配") 
	end
	mysql_opt:release_res()

	sql = "select default_identity from t_users where `id` = "..eims_safety(n_ownerid).." or `mobile` = "..eims_safety(n_ownerid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "新用户不存在") 
	end
	mysql_opt:release_res()

	sql = "update t_sites set owner_id = "..eims_safety(n_ownerid).." where `id` = "..eims_safety(siteid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "delete from t_site_user_id_list where site_id = "..eims_safety(siteid).." and (user_id = "..eims_safety(o_ownerid).." or user_id = "..eims_safety(n_ownerid)..") and group_id = -1"
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "update t_site_group set user_id = "..eims_safety(n_ownerid).." where site_id = "..eims_safety(siteid).." and user_id = "..eims_safety(o_ownerid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "update t_user_in_sitegroup set optioner_id = "..eims_safety(n_ownerid).." where site_id = "..eims_safety(siteid).." and optioner_id = "..eims_safety(o_ownerid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "update t_site_user_id_list set data_version = now() where site_id = "..eims_safety(siteid)
	sql = sql.." and user_id = "..o_ownerid.." and group_id > -1"
	result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end


---------------------------------------------
--
--	old: 0x36    增加站点使用者, 将一个已经存在用户增加到站点的使用者列表中(软件注册者、软件使用者、网站所有者都能创建网站使用者ID, 但要校验网站所属)
--	new: 307
---------------------------------------------
eims_add_site_user = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local allowdesign = xml_opt:get_node_value(get_label_path("data", "is_allow_design"))
	local allowedit = xml_opt:get_node_value(get_label_path("data", "is_allow_edit"))

	local sql = "select id from v_sites where (creater_id = "..eims_safety(userid).." or creater_soft_owner_id = "..eims_safety(userid).." or creater_soft_user_id = "..eims_safety(userid)
		  sql = sql.." or creater_site_owner_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid).." or owner_soft_owner_id = "..eims_safety(userid)
		  sql = sql.." or owner_soft_user_id = "..eims_safety(userid).." or owner_site_owner_id = "..eims_safety(userid)..") and `id` = "..eims_safety(siteid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "站点不存在或没有权限")
	end
	mysql_opt:release_res()

	sql = "select id from t_users where `id` = "..eims_safety(userid).." or `mobile` = "..eims_safety(userid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "用户不存在")
	end
	mysql_opt:release_res()

	sql = "select id from t_site_user_id_list where (site_id = "..eims_safety(siteid).." and ((user_id = "..eims_safety(userid).." and group_id = -1) or "
	sql = sql.."group_id in (select group_id from t_user_in_sitegroup where user_id = "..eims_safety(userid).."))) "
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "此用户已经是该站点的使用者")
	end
	mysql_opt:release_res()

	sql = "insert into t_site_user_id_list (site_id, user_id, is_allow_design, is_allow_edit_data) "
	sql = sql.."values ("..eims_safety(siteid)..", "..eims_safety(userid)..", "..eims_safety(allowdesign)..", "..eims_safety(allowedit)..")"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x37    移除站点使用者, 具有网站管理权限的用户, 将站点的某个使用者移除(使用者ID = -1 表示移除全部使用者)
--	new: 308
---------------------------------------------
eims_remove_site_user = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local userremoving = xml_opt:get_node_value(get_label_path("data", "optioner_id"))
	local sql = "select id from v_sites where (creater_id = "..eims_safety(userid).." or creater_soft_owner_id = "..eims_safety(userid).." or creater_soft_user_id = "..eims_safety(userid)
		  sql = sql.." or creater_site_owner_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid).." or owner_soft_owner_id = "..eims_safety(userid)
		  sql = sql.." or owner_soft_user_id = "..eims_safety(userid).." or owner_site_owner_id = "..eims_safety(userid)..") and `id` = "..eims_safety(siteid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "站点不存在或没有权限")
	end
	mysql_opt:release_res()

	if tonumber(userremoving) < 0 then
		sql = "delete from t_site_user_id_list where site_id = "..eims_safety(siteid)
		result = mysql_opt:oper_db(sql)
		if result ~= 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
	else
		sql = "select id from t_site_user_id_list where `site_id` = "..eims_safety(siteid).." and `user_id` = "..eims_safety(userid)
		result = mysql_opt:oper_db(sql)
		if result ~= 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
		rowcount = mysql_opt:get_row_count()
		if rowcount <= 0 then
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "此用户不是该站点的使用者")
		end
		mysql_opt:release_res()

		sql = "delete from t_site_user_id_list where site_id = "..eims_safety(siteid).." and user_id = "..eims_safety(userid)
		result = mysql_opt:oper_db(sql)
		if result ~= 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x3E user_id 把网 site_id 站转让给 user_id_12,并把user_id添加为网站site_id的使用者
--	new: 313
---------------------------------------------
eims_change_site_owner_set_owner_as_user = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local o_ownerid = xml_opt:get_node_value(get_label_path("data", "old_owner_id"))
	local n_ownerid = xml_opt:get_node_value(get_label_path("data", "new_owner_id"))
	local sql = "select `owner_id` from v_sites where (creater_id = "..eims_safety(userid).." or creater_soft_owner_id = "..eims_safety(userid).." or creater_soft_user_id = "..eims_safety(userid)
		  sql = sql.." or creater_site_owner_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid).." or owner_soft_owner_id = "..eims_safety(userid).." or owner_soft_user_id = "..eims_safety(userid)
		  sql = sql.." or owner_site_owner_id = "..eims_safety(userid)..") and `id` = "..eims_safety(siteid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	
	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "站点不存在或没有权限") 
	end

	local old_owner_id_db = mysql_opt:get_query_result(0, "owner_id")
	if old_owner_id_db ~= o_ownerid then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "原拥有者不匹配") 
	end
	mysql_opt:release_res()

	sql = "select default_identity from t_users where `id` = "..eims_safety(n_ownerid).." or `mobile` = "..eims_safety(n_ownerid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "新拥有者不存在") 
	end
	mysql_opt:release_res()

	sql = "update t_sites set owner_id = "..eims_safety(n_ownerid).." where `id` = "..eims_safety(siteid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "delete from t_site_user_id_list where site_id = "..eims_safety(siteid).." and user_id = "..eims_safety(n_ownerid).." and group_id = -1"
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		mysql_opt:rollback()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "select id from t_site_user_id_list where `site_id` = "..eims_safety(siteid).." and `user_id` = "..eims_safety(o_ownerid).." and group_id = -1"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		mysql_opt:rollback()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	if mysql_opt:get_row_count() > 0 then
		mysql_opt:release_res()

		sql = "update t_site_user_id_list set data_version = now() where site_id = "..eims_safety(siteid).." and user_id = "..eims_safety(o_ownerid)
		result = mysql_opt:oper_db_trans_exc_v2(sql, false)
		if result < 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			mysql_opt:rollback()
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
	else
		sql = "insert into t_site_user_id_list(site_id,user_id,is_allow_design,is_allow_edit_data)values("..eims_safety(siteid)..","..eims_safety(o_ownerid)..", 1, 1)"
		result = mysql_opt:oper_db_trans_exc_v2(sql,false)
		if result < 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			mysql_opt:rollback()
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
	end

	sql = "update t_site_group set user_id = "..eims_safety(n_ownerid).." where site_id = "..eims_safety(siteid).." and user_id = "..eims_safety(o_ownerid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		mysql_opt:rollback()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "update t_user_in_sitegroup set optioner_id = "..eims_safety(n_ownerid).." where site_id = "..eims_safety(siteid).." and optioner_id = "..eims_safety(o_ownerid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		mysql_opt:rollback()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "update t_site_user_id_list set user_id = "..eims_safety(n_ownerid).." where site_id = "..eims_safety(siteid).." and user_id = "..eims_safety(o_ownerid).." and group_id > -1"
	result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		mysql_opt:rollback()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()

end


---------------------------------------------
--
--	old: 0x70    根据 site_id 获取网站功能版本
--	new: 319
---------------------------------------------
eims_get_site_function_ver = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))

	local sql = "select id, `description` as `name`, model_id from t_std_versions where id = (select max(version_id) from t_site_expands where site_id = "..eims_safety(siteid)..")"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "站点不存在") 
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")

	xml_opt:add_child_node(get_label_path("site_ver"), "", get_label_path("data"))
	xml_opt:add_child_node(get_label_path("ver_id"), mysql_opt:get_query_result(0, "id"), get_label_path("data", "site_ver"))
	xml_opt:add_child_node(get_label_path("name"), mysql_opt:get_query_result(0, "name"), get_label_path("data", "site_ver"))
	mysql_opt:release_res()

	sql = "select id, `description` as `name` from t_std_versions where model_id in (select model_id from t_site_expands where site_id = "..eims_safety(siteid)
	sql = sql.." group by model_id) order by id desc limit 0, 1"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "该站点版本已经是最新版本") 
	end

	xml_opt:add_child_node(get_label_path("ver"), "", get_label_path("data"))
	xml_opt:add_child_node(get_label_path("ver_id"), mysql_opt:get_query_result(0, "id"), get_label_path("data", "ver"))
	xml_opt:add_child_node(get_label_path("name"), mysql_opt:get_query_result(0, "name"), get_label_path("data", "ver"))
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


---------------------------------------------
--
--	old: 0x71    根据 site_id 获取DB系统数据库配置信息
--	new: none
---------------------------------------------
eims_get_site_db_config = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local type = xml_opt:get_node_value(get_label_path("data", "type"))
end


---------------------------------------------
--
--	old: 0x31    根据 user_id, 获取其下所有的 site, 可以是 user_id 创建的, 可以是他下级的用户创建的
--	new: 302
---------------------------------------------
eims_get_user_all_sites = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local dtver = xml_opt:get_node_value(get_label_path("data", "data_ver"))

	local sql = "select * from t_sites where (creater_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid)..")  and data_version > '"..eims_safety(dtver).."' order by `id`"
	--local sql = "select * from v_sites where (creater_id = "..eims_safety(userid).." or creater_soft_owner_id = "..eims_safety(userid).." or creater_soft_user_id = "..eims_safety(userid)
	--sql = sql.." or creater_site_owner_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid).." or owner_soft_owner_id = "..eims_safety(userid).." or owner_soft_user_id = "..eims_safety(userid).." or "
	--sql = sql.." owner_site_owner_id = "..eims_safety(userid)..") and data_version > '"..eims_safety(dtver).."' order by `id`"
	local result = mysql_opt:oper_db(sql)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")

	local rowcount = mysql_opt:get_row_count()
	local dl = get_label_path("data")
	local site = get_label_path("site")
	local sites = site.."s"
	xml_opt:add_child_node(sites, "", dl)
	for i = 0, rowcount - 1 do
		local t_app_id = mysql_opt:get_query_result(0, "application_id")
        local t_owner_id = mysql_opt:get_query_result(0, "owner_id")
        if tonumber(t_app_id) > 1 and t_owner_id ~= userid then
            --jump loop
        else
			xml_opt:add_child_node(site..tostring(i), "", dl.."/"..sites)
			local p = dl.."/"..sites.."/"..site..tostring(i)
			xml_opt:add_child_node(get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
			xml_opt:add_child_node(get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
			xml_opt:add_child_node(get_label_path("site_alias"), mysql_opt:get_query_result(i, "site_alias"), p)
			xml_opt:add_child_node(get_label_path("description"), mysql_opt:get_query_result(i, "description"), p)
			xml_opt:add_child_node(get_label_path("guid"), mysql_opt:get_query_result(i, "guid"), p)
			xml_opt:add_child_node(get_label_path("create_time"), mysql_opt:get_query_result(i, "create_time"), p)
			xml_opt:add_child_node(get_label_path("company_name"), mysql_opt:get_query_result(i, "company_name"), p)
			xml_opt:add_child_node(get_label_path("trade_type_id"), mysql_opt:get_query_result(i, "trade_type_id"), p)
			xml_opt:add_child_node(get_label_path("province_id"), mysql_opt:get_query_result(i, "province_id"), p)
			xml_opt:add_child_node(get_label_path("city_id"), mysql_opt:get_query_result(i, "city_id"), p)
			xml_opt:add_child_node(get_label_path("area_id"), mysql_opt:get_query_result(i, "area_id"), p)
			xml_opt:add_child_node(get_label_path("domain_name"), mysql_opt:get_query_result(i, "domain_name"), p)
			xml_opt:add_child_node(get_label_path("ftp_ip"), mysql_opt:get_query_result(i, "ftp_ip"), p)
			xml_opt:add_child_node(get_label_path("ftp_port"), mysql_opt:get_query_result(i, "ftp_port"), p)
			xml_opt:add_child_node(get_label_path("ftp_username"), mysql_opt:get_query_result(i, "ftp_username"), p)
			xml_opt:add_child_node(get_label_path("ftp_password"), mysql_opt:get_query_result(i, "ftp_password"), p)
			xml_opt:add_child_node(get_label_path("ftp_path"), mysql_opt:get_query_result(i, "ftp_path"), p)
			xml_opt:add_child_node(get_label_path("m_state"), mysql_opt:get_query_result(i, "m_state"), p)
			xml_opt:add_child_node(get_label_path("m_domain_name"), mysql_opt:get_query_result(i, "m_domain_name"), p)
			xml_opt:add_child_node(get_label_path("m_style_range"), mysql_opt:get_query_result(i, "m_style_range"), p)
			xml_opt:add_child_node(get_label_path("m_expire"), "1990-09-17 0:00:00", p)
			xml_opt:add_child_node(get_label_path("m_on"), "0", p)
			xml_opt:add_child_node(get_label_path("m_style"), "-1", p)
			xml_opt:add_child_node(get_label_path("is_deleted"), mysql_opt:get_query_byte_result(i, "is_deleted"), p)
			xml_opt:add_child_node(get_label_path("creater_id"), mysql_opt:get_query_result(i, "creater_id"), p)
			xml_opt:add_child_node(get_label_path("creater_soft_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("creater_soft_user_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("creater_site_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("builder_version"), mysql_opt:get_query_result(i, "builder_version"), p)
			xml_opt:add_child_node(get_label_path("owner_soft_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("owner_soft_user_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("owner_site_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			--xml_opt:add_child_node(get_label_path("is_allow_design"), mysql_opt:get_query_result(i, "is_allow_design"), p)
			--xml_opt:add_child_node(get_label_path("is_allow_edit_data"), mysql_opt:get_query_result(i, "is_allow_edit_data"), p)
			xml_opt:add_child_node(get_label_path("data_ver"), mysql_opt:get_query_result(i, "data_version"), p)
			xml_opt:add_child_node(get_label_path("telephone"), mysql_opt:get_query_result(i, "telephone"), p)
			xml_opt:add_child_node(get_label_path("fax"), mysql_opt:get_query_result(i, "fax"), p)
			xml_opt:add_child_node(get_label_path("postcode"), mysql_opt:get_query_result(i, "postcode"), p)
			xml_opt:add_child_node(get_label_path("icp_number"), mysql_opt:get_query_result(i, "icp_number"), p)
			xml_opt:add_child_node(get_label_path("manager_name"), mysql_opt:get_query_result(i, "manager_name"), p)
			xml_opt:add_child_node(get_label_path("manager_sex"), mysql_opt:get_query_byte_result(i, "manager_sex"), p)
			xml_opt:add_child_node(get_label_path("manager_eims_id"), mysql_opt:get_query_result(i, "manager_eims_id"), p)
			xml_opt:add_child_node(get_label_path("manager_mobile"), mysql_opt:get_query_result(i, "manager_mobile"), p)
			xml_opt:add_child_node(get_label_path("manager_phone"), mysql_opt:get_query_result(i, "manager_phone"), p)
			xml_opt:add_child_node(get_label_path("manager_fax"), mysql_opt:get_query_result(i, "manager_fax"), p)
			xml_opt:add_child_node(get_label_path("manager_home_addr"), mysql_opt:get_query_result(i, "manager_home_address"), p)
			xml_opt:add_child_node(get_label_path("manager_post_code"), mysql_opt:get_query_result(i, "manager_post_code"), p)
			xml_opt:add_child_node(get_label_path("manager_email"), mysql_opt:get_query_result(i, "manager_email"), p)
			xml_opt:add_child_node(get_label_path("app_id"), mysql_opt:get_query_result(i, "application_id"), p)
			xml_opt:add_child_node(get_label_path("status"), mysql_opt:get_query_result(i, "status"), p)
			xml_opt:add_child_node(get_label_path("is_show_on_desk"), mysql_opt:get_query_result(i, "is_show_on_desk"), p)
			--xml_opt:add_child_node(get_label_path("group_id"), mysql_opt:get_query_result(i, "group_id"), p)
			xml_opt:add_child_node(get_label_path("count_password"), mysql_opt:get_query_result(i, "count_password"), p)
			xml_opt:add_child_node(get_label_path("source"), mysql_opt:get_query_result(i, "source"), p)
		end
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x32    根据 user_id, 获取其所有的 site(只是作为网站所有者)
--	new: 303
---------------------------------------------
eims_get_owned_all_sites = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local dtver = xml_opt:get_node_value(get_label_path("data", "data_ver"))

	local sql = "select * from t_sites where owner_id = "..eims_safety(userid).." order by `id`"
	local result = mysql_opt:oper_db(sql)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local rowcount = mysql_opt:get_row_count()
	local dl = get_label_path("data")
	local site = get_label_path("site")
	local sites = site.."s"
	xml_opt:add_child_node(sites, "", dl)
	for i = 0, rowcount - 1 do
		local t_app_id = mysql_opt:get_query_result(i, "application_id")
        local t_owner_id = mysql_opt:get_query_result(i, "owner_id")
        if tonumber(t_app_id) > 1 and t_owner_id ~= userid then
            --jump loop
        else
			xml_opt:add_child_node(site..tostring(i), "", dl.."/"..sites)
			local p = dl.."/"..sites.."/"..site..tostring(i)
			xml_opt:add_child_node(get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
			xml_opt:add_child_node(get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
			xml_opt:add_child_node(get_label_path("site_alias"), mysql_opt:get_query_result(i, "site_alias"), p)
			xml_opt:add_child_node(get_label_path("description"), mysql_opt:get_query_result(i, "description"), p)
			xml_opt:add_child_node(get_label_path("guid"), mysql_opt:get_query_result(i, "guid"), p)
			xml_opt:add_child_node(get_label_path("create_time"), mysql_opt:get_query_result(i, "create_time"), p)
			xml_opt:add_child_node(get_label_path("company_name"), mysql_opt:get_query_result(i, "company_name"), p)
			xml_opt:add_child_node(get_label_path("trade_type_id"), mysql_opt:get_query_result(i, "trade_type_id"), p)
			xml_opt:add_child_node(get_label_path("province_id"), mysql_opt:get_query_result(i, "province_id"), p)
			xml_opt:add_child_node(get_label_path("city_id"), mysql_opt:get_query_result(i, "city_id"), p)
			xml_opt:add_child_node(get_label_path("area_id"), mysql_opt:get_query_result(i, "area_id"), p)
			xml_opt:add_child_node(get_label_path("domain_name"), mysql_opt:get_query_result(i, "domain_name"), p)
			xml_opt:add_child_node(get_label_path("ftp_ip"), mysql_opt:get_query_result(i, "ftp_ip"), p)
			xml_opt:add_child_node(get_label_path("ftp_port"), mysql_opt:get_query_result(i, "ftp_port"), p)
			xml_opt:add_child_node(get_label_path("ftp_username"), mysql_opt:get_query_result(i, "ftp_username"), p)
			xml_opt:add_child_node(get_label_path("ftp_password"), mysql_opt:get_query_result(i, "ftp_password"), p)
			xml_opt:add_child_node(get_label_path("ftp_path"), mysql_opt:get_query_result(i, "ftp_path"), p)
			xml_opt:add_child_node(get_label_path("m_state"), mysql_opt:get_query_result(i, "m_state"), p)
			xml_opt:add_child_node(get_label_path("m_domain_name"), mysql_opt:get_query_result(i, "m_domain_name"), p)
			xml_opt:add_child_node(get_label_path("m_style_range"), mysql_opt:get_query_result(i, "m_style_range"), p)
			xml_opt:add_child_node(get_label_path("m_expire"), "1990-09-17 0:00:00", p)
			xml_opt:add_child_node(get_label_path("m_on"), "0", p)
			xml_opt:add_child_node(get_label_path("m_style"), "-1", p)
			xml_opt:add_child_node(get_label_path("is_deleted"), mysql_opt:get_query_byte_result(i, "is_deleted"), p)
			xml_opt:add_child_node(get_label_path("creater_id"), mysql_opt:get_query_result(i, "creater_id"), p)
			xml_opt:add_child_node(get_label_path("creater_soft_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("creater_soft_user_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("creater_site_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("builder_version"), mysql_opt:get_query_result(i, "builder_version"), p)
			xml_opt:add_child_node(get_label_path("owner_soft_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("owner_soft_user_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("owner_site_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			--xml_opt:add_child_node(get_label_path("is_allow_design"), mysql_opt:get_query_result(i, "is_allow_design"), p)
			--xml_opt:add_child_node(get_label_path("is_allow_edit_data"), mysql_opt:get_query_result(i, "is_allow_edit_data"), p)
			xml_opt:add_child_node(get_label_path("data_ver"), mysql_opt:get_query_result(i, "data_version"), p)
			xml_opt:add_child_node(get_label_path("telephone"), mysql_opt:get_query_result(i, "telephone"), p)
			xml_opt:add_child_node(get_label_path("fax"), mysql_opt:get_query_result(i, "fax"), p)
			xml_opt:add_child_node(get_label_path("postcode"), mysql_opt:get_query_result(i, "postcode"), p)
			xml_opt:add_child_node(get_label_path("icp_number"), mysql_opt:get_query_result(i, "icp_number"), p)
			xml_opt:add_child_node(get_label_path("manager_name"), mysql_opt:get_query_result(i, "manager_name"), p)
			xml_opt:add_child_node(get_label_path("manager_sex"), mysql_opt:get_query_byte_result(i, "manager_sex"), p)
			xml_opt:add_child_node(get_label_path("manager_eims_id"), mysql_opt:get_query_result(i, "manager_eims_id"), p)
			xml_opt:add_child_node(get_label_path("manager_mobile"), mysql_opt:get_query_result(i, "manager_mobile"), p)
			xml_opt:add_child_node(get_label_path("manager_phone"), mysql_opt:get_query_result(i, "manager_phone"), p)
			xml_opt:add_child_node(get_label_path("manager_fax"), mysql_opt:get_query_result(i, "manager_fax"), p)
			xml_opt:add_child_node(get_label_path("manager_home_addr"), mysql_opt:get_query_result(i, "manager_home_address"), p)
			xml_opt:add_child_node(get_label_path("manager_post_code"), mysql_opt:get_query_result(i, "manager_post_code"), p)
			xml_opt:add_child_node(get_label_path("manager_email"), mysql_opt:get_query_result(i, "manager_email"), p)
			xml_opt:add_child_node(get_label_path("app_id"), mysql_opt:get_query_result(i, "application_id"), p)
			xml_opt:add_child_node(get_label_path("status"), mysql_opt:get_query_result(i, "status"), p)
			xml_opt:add_child_node(get_label_path("is_show_on_desk"), mysql_opt:get_query_result(i, "is_show_on_desk"), p)
			--xml_opt:add_child_node(get_label_path("group_id"), mysql_opt:get_query_result(i, "group_id"), p)
			xml_opt:add_child_node(get_label_path("count_password"), mysql_opt:get_query_result(i, "count_password"), p)
			xml_opt:add_child_node(get_label_path("source"), mysql_opt:get_query_result(i, "source"), p)
		end
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x33    根据 user_id, 获取其所有的具有使用权的 site
--	new: 304
---------------------------------------------
eims_get_used_all_sites = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local dtver = xml_opt:get_node_value(get_label_path("data", "data_ver"))

	local sql = "select a.*, b.is_allow_design, b.is_allow_edit_data, b.data_version as data_version_lists, b.group_id "
	sql = sql.."from t_sites as a, (select * from t_site_user_id_list where ((user_id = "..eims_safety(userid).." and group_id = -1) or "
	sql = sql.."group_id = -3 or group_id in (select group_id from t_user_in_sitegroup where user_id = "..eims_safety(userid)..")) and "
	sql = sql.."t_site_user_id_list.data_version > '"..eims_safety(dtver).."') as b where a.is_deleted = 0 and a.`id` = b.site_id"
	--print(sql)
	local result = mysql_opt:oper_db(sql)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local rowcount = mysql_opt:get_row_count()

	local dl = get_label_path("data")
	local site = get_label_path("site")
	local sites = site.."s"
	xml_opt:add_child_node(sites, "", dl)
	for i = 0, rowcount - 1 do
		local groupid = mysql_opt:get_query_result(i, "group_id")
		local ownerid = mysql_opt:get_query_result(i, "owner_id")
		if groupid == -3 and ownerid == userid then
			--jump loop
		else
			xml_opt:add_child_node(site..tostring(i), "", dl.."/"..sites)
			local p = dl.."/"..sites.."/"..site..tostring(i)
			xml_opt:add_child_node(get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
			xml_opt:add_child_node(get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
			xml_opt:add_child_node(get_label_path("site_alias"), mysql_opt:get_query_result(i, "site_alias"), p)
			xml_opt:add_child_node(get_label_path("description"), mysql_opt:get_query_result(i, "description"), p)
			xml_opt:add_child_node(get_label_path("guid"), mysql_opt:get_query_result(i, "guid"), p)
			xml_opt:add_child_node(get_label_path("create_time"), mysql_opt:get_query_result(i, "create_time"), p)
			xml_opt:add_child_node(get_label_path("company_name"), mysql_opt:get_query_result(i, "company_name"), p)
			xml_opt:add_child_node(get_label_path("trade_type_id"), mysql_opt:get_query_result(i, "trade_type_id"), p)
			xml_opt:add_child_node(get_label_path("province_id"), mysql_opt:get_query_result(i, "province_id"), p)
			xml_opt:add_child_node(get_label_path("city_id"), mysql_opt:get_query_result(i, "city_id"), p)
			xml_opt:add_child_node(get_label_path("area_id"), mysql_opt:get_query_result(i, "area_id"), p)
			xml_opt:add_child_node(get_label_path("domain_name"), mysql_opt:get_query_result(i, "domain_name"), p)
			xml_opt:add_child_node(get_label_path("ftp_ip"), mysql_opt:get_query_result(i, "ftp_ip"), p)
			xml_opt:add_child_node(get_label_path("ftp_port"), mysql_opt:get_query_result(i, "ftp_port"), p)
			xml_opt:add_child_node(get_label_path("ftp_username"), mysql_opt:get_query_result(i, "ftp_username"), p)
			xml_opt:add_child_node(get_label_path("ftp_password"), mysql_opt:get_query_result(i, "ftp_password"), p)
			xml_opt:add_child_node(get_label_path("ftp_path"), mysql_opt:get_query_result(i, "ftp_path"), p)
			xml_opt:add_child_node(get_label_path("m_state"), mysql_opt:get_query_result(i, "m_state"), p)
			xml_opt:add_child_node(get_label_path("m_domain_name"), mysql_opt:get_query_result(i, "m_domain_name"), p)
			xml_opt:add_child_node(get_label_path("m_style_range"), mysql_opt:get_query_result(i, "m_style_range"), p)
			xml_opt:add_child_node(get_label_path("m_expire"), "1990-09-17 0:00:00", p)
			xml_opt:add_child_node(get_label_path("m_on"), "0", p)
			xml_opt:add_child_node(get_label_path("m_style"), "-1", p)
			xml_opt:add_child_node(get_label_path("is_deleted"), mysql_opt:get_query_byte_result(i, "is_deleted"), p)
			xml_opt:add_child_node(get_label_path("creater_id"), mysql_opt:get_query_result(i, "creater_id"), p)
			xml_opt:add_child_node(get_label_path("creater_soft_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("creater_soft_user_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("creater_site_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("builder_version"), mysql_opt:get_query_result(i, "builder_version"), p)
			xml_opt:add_child_node(get_label_path("owner_soft_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("owner_soft_user_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("owner_site_owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
			xml_opt:add_child_node(get_label_path("is_allow_design"), mysql_opt:get_query_byte_result(i, "is_allow_design"), p)
			xml_opt:add_child_node(get_label_path("is_allow_edit_data"), mysql_opt:get_query_byte_result(i, "is_allow_edit_data"), p)
			xml_opt:add_child_node(get_label_path("data_ver"), mysql_opt:get_query_result(i, "data_version"), p)
			xml_opt:add_child_node(get_label_path("telephone"), mysql_opt:get_query_result(i, "telephone"), p)
			xml_opt:add_child_node(get_label_path("fax"), mysql_opt:get_query_result(i, "fax"), p)
			xml_opt:add_child_node(get_label_path("postcode"), mysql_opt:get_query_result(i, "postcode"), p)
			xml_opt:add_child_node(get_label_path("icp_number"), mysql_opt:get_query_result(i, "icp_number"), p)
			xml_opt:add_child_node(get_label_path("manager_name"), mysql_opt:get_query_result(i, "manager_name"), p)
			xml_opt:add_child_node(get_label_path("manager_sex"), mysql_opt:get_query_byte_result(i, "manager_sex"), p)
			xml_opt:add_child_node(get_label_path("manager_eims_id"), mysql_opt:get_query_result(i, "manager_eims_id"), p)
			xml_opt:add_child_node(get_label_path("manager_mobile"), mysql_opt:get_query_result(i, "manager_mobile"), p)
			xml_opt:add_child_node(get_label_path("manager_phone"), mysql_opt:get_query_result(i, "manager_phone"), p)
			xml_opt:add_child_node(get_label_path("manager_fax"), mysql_opt:get_query_result(i, "manager_fax"), p)
			xml_opt:add_child_node(get_label_path("manager_home_addr"), mysql_opt:get_query_result(i, "manager_home_address"), p)
			xml_opt:add_child_node(get_label_path("manager_post_code"), mysql_opt:get_query_result(i, "manager_post_code"), p)
			xml_opt:add_child_node(get_label_path("manager_email"), mysql_opt:get_query_result(i, "manager_email"), p)
			xml_opt:add_child_node(get_label_path("app_id"), mysql_opt:get_query_result(i, "application_id"), p)
			xml_opt:add_child_node(get_label_path("status"), mysql_opt:get_query_result(i, "status"), p)
			xml_opt:add_child_node(get_label_path("is_show_on_desk"), mysql_opt:get_query_result(i, "is_show_on_desk"), p)
			xml_opt:add_child_node(get_label_path("group_id"), mysql_opt:get_query_result(i, "group_id"), p)
			xml_opt:add_child_node(get_label_path("count_password"), mysql_opt:get_query_result(i, "count_password"), p)
			xml_opt:add_child_node(get_label_path("source"), mysql_opt:get_query_result(i, "source"), p)
		end
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x32    根据 user_id, 获取其所有的 site(只是作为网站所有者)
--	new: 330
---------------------------------------------
eims_get_user_all_sites_as_owner = function ( xml_opt, mysql_opt )
	-- body
	--print("330 start")
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	--print("330 1")
	--local sql = "select id from v_sites where is_deleted = 0 and (creater_id = "..eims_safety(userid).." or creater_soft_owner_id = "..eims_safety(userid).." or "
	--sql = sql.." creater_soft_user_id = "..eims_safety(userid).." or creater_site_owner_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid).." or owner_soft_owner_id = "..eims_safety(userid)
	--sql = sql.." or owner_soft_user_id = "..eims_safety(userid).." or owner_site_owner_id = "..eims_safety(userid)..") order by `id`"
	local sql = "select `s`.`id` AS `id` from t_sites s left join t_users u on s.creater_id = u.id where u.id = "..eims_safety(userid).." and is_deleted = 0 union"..
			     " select `s`.`id` AS `id` from t_sites s left join t_users u on s.owner_id = u.id where u.id = "..eims_safety(userid).." and is_deleted = 0"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	--print("330 2")

	local rowcount = mysql_opt:get_row_count()
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local dl = get_label_path("data")
	local site = get_label_path("site")
	local sites = site.."s"
	xml_opt:add_child_node(sites, "", dl)
	for i = 0, rowcount - 1 do
		local p = dl.."/"..sites.."/"..site..tostring(i)
		xml_opt:add_child_node(site..tostring(i), "", dl.."/"..sites)
		xml_opt:add_child_node(get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
	end
	mysql_opt:release_res()
	--print("330 end")
	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x34    根据 site_id, 获取其所有的具有使用权的 user(对网站有管理权的用户才能操作)
--	new: 331
---------------------------------------------
eims_get_user_all_sites_as_user = function ( xml_opt, mysql_opt )
	-- body
	--print("331 start")
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	--local sql = "select a.id from v_sites as a, (select * from t_site_user_id_list where ((user_id = "..eims_safety(userid).." and (group_id = -1)) "
	--sql = sql.."or group_id = -3 or group_id in (select group_id from t_user_in_sitegroup where user_id = "..eims_safety(userid).."))) as b "
	--sql = sql.."where a.is_deleted = 0 and a.`id` = b.site_id order by `id`"

	local sql = "select a.id from t_sites as a, (select * from t_site_user_id_list where ((user_id = "..eims_safety(userid).." and (group_id = -1)) "
	sql = sql.."or group_id = -3 or group_id in (select group_id from t_user_in_sitegroup where user_id = "..eims_safety(userid).."))) as b "
	sql = sql.."where a.is_deleted = 0 and a.`id` = b.site_id order by `id`"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local rowcount = mysql_opt:get_row_count()
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local dl = get_label_path("data")
	local site = get_label_path("site")
	local sites = site.."s"
	xml_opt:add_child_node(sites, "", dl)
	for i = 0, rowcount - 1 do
		local p = dl.."/"..sites.."/"..site..tostring(i)
		xml_opt:add_child_node(site..tostring(i), "", dl.."/"..sites)
		xml_opt:add_child_node(get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
	end
	mysql_opt:release_res()
	--print("331 end")
	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x70    根据 site_id 获取网站功能版本
--	new: 332
---------------------------------------------
eims_get_site_versions = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local sql = "select id, `description` as `name`, model_id from t_std_versions where id = (select max(version_id) from t_site_expands where site_id = "..eims_safety(siteid)..")"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "站点不存在") 
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local dl = get_label_path("data")
	local st = get_label_path("site")
	xml_opt:add_child_node(st, "", dl)
	xml_opt:add_child_node(get_label_path("ver_id"), mysql_opt:get_query_result(0, "id"), dl.."/"..st)
	xml_opt:add_child_node(get_label_path("name"), mysql_opt:get_query_result(0, "name"), dl.."/"..st)
	mysql_opt:release_res()

	sql = "select id, `description` as `name` from t_std_versions where model_id in (select model_id from t_site_expands "
	sql = sql.."where site_id = "..eims_safety(siteid).." group by model_id) order by id desc limit 0, 1"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "站点的版本信息不存在") 
	end

	local dl = get_label_path("data")
	local v = get_label_path("version")
	xml_opt:add_child_node(v, "", dl)
	xml_opt:add_child_node(get_label_path("ver_id"), mysql_opt:get_query_result(0, "id"), dl.."/"..v)
	xml_opt:add_child_node(get_label_path("name"), mysql_opt:get_query_result(0, "name"), dl.."/"..v)
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x7E    修改网站信息
--	new: 318
---------------------------------------------
eims_edit_site_info_db = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
    local siteid = xml_opt:get_node_value(get_label_path("data", "site_id")) 
    local sitealias = xml_opt:get_node_value(get_label_path("data", "site_alias")) 
    local companyname = xml_opt:get_node_value(get_label_path("data", "company_name")) 
    local shortcomname = xml_opt:get_node_value(get_label_path("data", "short_com_name")) 
    local domainname = xml_opt:get_node_value(get_label_path("data", "domain_name")) 
    local telphone = xml_opt:get_node_value(get_label_path("data", "telephone")) 
    local fax = xml_opt:get_node_value(get_label_path("data", "fax")) 
    local postcode = xml_opt:get_node_value(get_label_path("data", "postcode")) 
    local icpnum = xml_opt:get_node_value(get_label_path("data", "icp_num")) 
    local addr = xml_opt:get_node_value(get_label_path("data", "address")) 
    local tradetypeid = xml_opt:get_node_value(get_label_path("data", "trade_type_id")) 
    local provinceid = xml_opt:get_node_value(get_label_path("data", "province_id")) 
    local cityid = xml_opt:get_node_value(get_label_path("data", "city_id")) 
    local areaid = xml_opt:get_node_value(get_label_path("data", "area_id")) 
    local mdomainname = xml_opt:get_node_value(get_label_path("data", "m_domain_name")) 

    local sql = "select id from v_sites where (creater_id = "..eims_safety(userid).." or creater_soft_owner_id = "..eims_safety(userid).." or creater_soft_user_id = "..eims_safety(userid).." "
    sql = sql.."or creater_site_owner_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid).." or owner_soft_owner_id = "..eims_safety(userid).." or owner_soft_user_id = "..eims_safety(userid).." "
    sql = sql.."or owner_site_owner_id = "..eims_safety(userid)..") and `id` = "..eims_safety(siteid)
    local result = mysql_opt:oper_db(sql)
    if result ~= 0 then
    	logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
    end
    local rowcount = mysql_opt:get_row_count()
    if rowcount <= 0 then
    	return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "站点不存在或没有权限") 
    end
    mysql_opt:release_res()

    sql = "update t_sites set `site_alias` = '"..eims_safety(sitealias).."', company_name = '"..eims_safety(companyname).."', trade_type_id = "..eims_safety(tradetypeid)..", "
    sql = sql.."province_id = "..eims_safety(provinceid)..", city_id = "..eims_safety(cityid)..", area_id = "..eims_safety(areaid)..", domain_name = '"..eims_safety(domainname).."', "
    sql = sql.."`telephone` = '"..eims_safety(telphone).."', "
    sql = sql.."`fax` = '"..eims_safety(fax).."', postcode = '"..eims_safety(postcode).."', icp_number = '"..eims_safety(icpnum).."', `address` = '"..eims_safety(addr).."', "
    sql = sql.."short_company_name = '"..eims_safety(shortcomname).."' where `id` = "..eims_safety(siteid)

    result = mysql_opt:oper_db_trans_exc_v2(sql, false)
    if result < 0 then
    	logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
    end

    sql = "update t_site_user_id_list set data_version = now() where site_id = "..eims_safety(siteid)
    result = mysql_opt:oper_db_trans_exc_v2(sql, false)
    if result < 0 then
    	logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
    end

    sql = "update t_sites set m_domain_name = '"..eims_safety(mdomainname).."' where id = "..eims_safety(siteid)
    result = mysql_opt:oper_db_trans_exc_v2(sql, true)
    if result < 0 then
    	logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
    end
    xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
    return xml_opt:create_xml_string()
end



