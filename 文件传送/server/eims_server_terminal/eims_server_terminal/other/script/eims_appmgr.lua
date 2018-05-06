------------------------------------------------------------------------------
--
--	application manager
--
------------------------------------------------------------------------------

package.path = package.path ..";./?.lua;../other/script/?.lua;./script/?.lua"

require("eims_log")
require("eims_error")
require("eims_common")
require("eims_message")


------------------------------------------------------------------------------
--
--	get apps list while data_ver bigger than user
--	new ver: 601
--	old ver: 0x50    获取云应用信息
--
------------------------------------------------------------------------------
eims_get_apps_info = function (xml_opt, mysql_opt)
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local data_ver = xml_opt:get_node_value(get_label_path("data", "data_ver"))
	local data_type = xml_opt:get_node_value(get_label_path("data", "data_type"))
	local sql = "select * from t_applications where state <> 0 and data_version > '"..eims_safety(data_ver).."' order by `id`"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local app = get_label_path("app")
	local apps = app.."s"
	xml_opt:add_child_node(apps, "", data)
	local rowcount = mysql_opt:get_row_count()
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(app..tostring(i), "", data.."/"..apps)
		local p = data.."/"..apps.."/"..app..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
		xml_opt:add_child_node( get_label_path("create_time"), mysql_opt:get_query_result(i, "create_time"), p)
		xml_opt:add_child_node( get_label_path("app_type_id"), mysql_opt:get_query_result(i, "application_type_id"), p)
		xml_opt:add_child_node( get_label_path("trade_type_id"), mysql_opt:get_query_result(i, "trade_type_id"), p)
		xml_opt:add_child_node( get_label_path("trade_type_detail_id"), mysql_opt:get_query_result(i, "trade_type_detail_id"), p)
		xml_opt:add_child_node( get_label_path("brief_description"), mysql_opt:get_query_result(i, "brief_description"), p)
		xml_opt:add_child_node( get_label_path("description"), mysql_opt:get_query_result(i, "description"), p)
		xml_opt:add_child_node( get_label_path("features"), mysql_opt:get_query_result(i, "features"), p)
		xml_opt:add_child_node( get_label_path("fees"), mysql_opt:get_query_result(i, "fees"), p)
		xml_opt:add_child_node( get_label_path("version"), mysql_opt:get_query_result(i, "version"), p)
		xml_opt:add_child_node( get_label_path("is_commend"), mysql_opt:get_query_byte_result(i, "is_commend"), p)
		xml_opt:add_child_node( get_label_path("commend_desc1"), mysql_opt:get_query_result(i, "commend_description1"), p)
		xml_opt:add_child_node( get_label_path("commend_desc2"), mysql_opt:get_query_result(i, "commend_description2"), p)
		xml_opt:add_child_node( get_label_path("commend_desc3"), mysql_opt:get_query_result(i, "commend_description3"), p)
		xml_opt:add_child_node( get_label_path("price"), mysql_opt:get_query_result(i, "price"), p)
		xml_opt:add_child_node( get_label_path("price_unit"), mysql_opt:get_query_result(i, "price_unit"), p)
		xml_opt:add_child_node( get_label_path("vote_high"), mysql_opt:get_query_result(i, "vote_high"), p)
		xml_opt:add_child_node( get_label_path("vote_medium"), mysql_opt:get_query_result(i, "vote_medium"), p)
		xml_opt:add_child_node( get_label_path("vote_bad"), mysql_opt:get_query_result(i, "vote_bad"), p)
		xml_opt:add_child_node( get_label_path("icon"), mysql_opt:get_query_result(i, "icon"), p)
		xml_opt:add_child_node( get_label_path("is_commend_top"), mysql_opt:get_query_byte_result(i, "is_commend_top"), p)
		xml_opt:add_child_node( get_label_path("commend_top_image"), mysql_opt:get_query_result(i, "commend_top_image"), p)
		xml_opt:add_child_node( get_label_path("user_id"), mysql_opt:get_query_result(i, "user_id"), p)
		xml_opt:add_child_node( get_label_path("company_name"), mysql_opt:get_query_result(i, "company_name"), p)
		xml_opt:add_child_node( get_label_path("telephone"), mysql_opt:get_query_result(i, "telephone"), p)
		xml_opt:add_child_node( get_label_path("email"), mysql_opt:get_query_result(i, "email"), p)
		xml_opt:add_child_node( get_label_path("fax"), mysql_opt:get_query_result(i, "fax"), p)
		xml_opt:add_child_node( get_label_path("state"), mysql_opt:get_query_result(i, "state"), p)
		xml_opt:add_child_node( get_label_path("order"), mysql_opt:get_query_result(i, "order"), p)
		xml_opt:add_child_node( get_label_path("url_target_new"), mysql_opt:get_query_result(i, "url_target_new"), p)
		xml_opt:add_child_node( get_label_path("data_ver"), mysql_opt:get_query_result(i, "data_version"), p)
		xml_opt:add_child_node( get_label_path("is_auto_install"), mysql_opt:get_query_result(i, "is_auto_install"), p)
		xml_opt:add_child_node( get_label_path("is_private"), mysql_opt:get_query_result(i, "is_private"), p)
		xml_opt:add_child_node( get_label_path("is_system"), mysql_opt:get_query_result(i, "is_system"), p)
		xml_opt:add_child_node( get_label_path("is_show_on_desk"), mysql_opt:get_query_result(i, "is_show_on_desk"), p)
		xml_opt:add_child_node( get_label_path("install_count"), mysql_opt:get_query_result(i, "install_count"), p)
		xml_opt:add_child_node( get_label_path("all_user_count"), mysql_opt:get_query_result(i, "all_user_count"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


------------------------------------------------------------------------------
--
--	get one app's detail information
--	new ver: 615
--	old ver: 0x6D
--
------------------------------------------------------------------------------
eims_get_app_detail = function (xml_opt, mysql_opt)
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local appid = xml_opt:get_node_value(get_label_path("data", "app_id"))
	--local sql = "select id,name,create_time,application_type_id,trade_type_id,trade_type_detail_id,brief_description,description,features,fees,version,is_commend, "
	--      sql = sql.."commend_description1,commend_description2,commend_description3,price,price_unit,vote_high,vote_medium,vote_bad,is_commend_top,user_id,"
	--      sql = sql.."company_name,telephone,email,fax,state,order,url_target_new,data_version,is_auto_install,is_private,is_system,is_show_on_desk,install_count,"
	--      sql = sql.."all_user_count from t_applications where state <> 0 and id = "..appid
	local sql = "select * from t_applications where state <> 0 and id = "..eims_safety(appid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local app = get_label_path("app")
	xml_opt:add_child_node(app, "", data)
	local rowcount = mysql_opt:get_row_count()
	if rowcount > 0 then
		local p = data.."/"..app
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(0, "id"), p)
		xml_opt:add_child_node( get_label_path("name"), mysql_opt:get_query_result(0, "name"), p)
		xml_opt:add_child_node( get_label_path("create_time"), mysql_opt:get_query_result(0, "create_time"), p)
		xml_opt:add_child_node( get_label_path("app_type_id"), mysql_opt:get_query_result(0, "application_type_id"), p)
		xml_opt:add_child_node( get_label_path("trade_type_id"), mysql_opt:get_query_result(0, "trade_type_id"), p)
		xml_opt:add_child_node( get_label_path("trade_type_detail_id"), mysql_opt:get_query_result(0, "trade_type_detail_id"), p)
		xml_opt:add_child_node( get_label_path("brief_description"), mysql_opt:get_query_result(0, "brief_description"), p)
		xml_opt:add_child_node( get_label_path("description"), mysql_opt:get_query_result(0, "description"), p)
		xml_opt:add_child_node( get_label_path("features"), mysql_opt:get_query_result(0, "features"), p)
		xml_opt:add_child_node( get_label_path("fees"), mysql_opt:get_query_result(0, "fees"), p)
		xml_opt:add_child_node( get_label_path("version"), mysql_opt:get_query_result(0, "version"), p)
		xml_opt:add_child_node( get_label_path("is_commend"), mysql_opt:get_query_byte_result(0, "is_commend"), p)
		xml_opt:add_child_node( get_label_path("commend_desc1"), mysql_opt:get_query_result(0, "commend_description1"), p)
		xml_opt:add_child_node( get_label_path("commend_desc2"), mysql_opt:get_query_result(0, "commend_description2"), p)
		xml_opt:add_child_node( get_label_path("commend_desc3"), mysql_opt:get_query_result(0, "commend_description3"), p)
		xml_opt:add_child_node( get_label_path("price"), mysql_opt:get_query_result(0, "price"), p)
		xml_opt:add_child_node( get_label_path("price_unit"), mysql_opt:get_query_result(0, "price_unit"), p)
		xml_opt:add_child_node( get_label_path("vote_high"), mysql_opt:get_query_result(0, "vote_high"), p)
		xml_opt:add_child_node( get_label_path("vote_medium"), mysql_opt:get_query_result(0, "vote_medium"), p)
		xml_opt:add_child_node( get_label_path("vote_bad"), mysql_opt:get_query_result(0, "vote_bad"), p)
		xml_opt:add_child_node( get_label_path("icon"), mysql_opt:get_query_result(0, "icon"), p)
		xml_opt:add_child_node( get_label_path("is_commend_top"), mysql_opt:get_query_byte_result(0, "is_commend_top"), p)
		xml_opt:add_child_node( get_label_path("commend_top_image"), mysql_opt:get_query_result(0, "commend_top_image"), p)
		xml_opt:add_child_node( get_label_path("user_id"), mysql_opt:get_query_result(0, "user_id"), p)
		xml_opt:add_child_node( get_label_path("company_name"), mysql_opt:get_query_result(0, "company_name"), p)
		xml_opt:add_child_node( get_label_path("telephone"), mysql_opt:get_query_result(0, "telephone"), p)
		xml_opt:add_child_node( get_label_path("email"), mysql_opt:get_query_result(0, "email"), p)
		xml_opt:add_child_node( get_label_path("fax"), mysql_opt:get_query_result(0, "fax"), p)
		xml_opt:add_child_node( get_label_path("state"), mysql_opt:get_query_result(0, "state"), p)
		xml_opt:add_child_node( get_label_path("order"), mysql_opt:get_query_result(0, "order"), p)
		xml_opt:add_child_node( get_label_path("url_target_new"), mysql_opt:get_query_result(0, "url_target_new"), p)
		xml_opt:add_child_node( get_label_path("data_ver"), mysql_opt:get_query_result(0, "data_version"), p)
		xml_opt:add_child_node( get_label_path("is_auto_install"), mysql_opt:get_query_result(0, "is_auto_install"), p)
		xml_opt:add_child_node( get_label_path("is_private"), mysql_opt:get_query_result(0, "is_private"), p)
		xml_opt:add_child_node( get_label_path("is_system"), mysql_opt:get_query_result(0, "is_system"), p)
		xml_opt:add_child_node( get_label_path("is_show_on_desk"), mysql_opt:get_query_result(0, "is_show_on_desk"), p)
		xml_opt:add_child_node( get_label_path("install_count"), mysql_opt:get_query_result(0, "install_count"), p)
		xml_opt:add_child_node( get_label_path("all_user_count"), mysql_opt:get_query_result(0, "all_user_count"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


------------------------------------------------------------------------------
--
--	get user's apply apps
--	new ver: 606
-- 	old ver: 0x52
--
------------------------------------------------------------------------------
eims_get_user_application_apps = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local sql = "select id,user_id,try_time,application_id,company_name,contact,telephone,email,fax,memo,handle_result,handle_user_id,handle_time "
		  sql = sql.."from t_try_applications where user_id = "..eims_safety(userid).." order by `id`"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local app = get_label_path("app")
	local apps = app.."s"
	xml_opt:add_child_node(apps, "", data)
	local rowcount = mysql_opt:get_row_count()
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(app..tostring(i), "", data.."/"..apps)
		local p = data.."/"..apps.."/"..app..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("user_id"), mysql_opt:get_query_result(i, "user_id"), p)
		xml_opt:add_child_node( get_label_path("try_time"), mysql_opt:get_query_result(i, "try_time"), p)
		xml_opt:add_child_node( get_label_path("app_id"), mysql_opt:get_query_result(i, "application_id"), p)
		xml_opt:add_child_node( get_label_path("company_name"), mysql_opt:get_query_result(i, "company_name"), p)
		xml_opt:add_child_node( get_label_path("contact"), mysql_opt:get_query_result(i, "contact"), p)
		xml_opt:add_child_node( get_label_path("telephone"), mysql_opt:get_query_result(i, "telephone"), p)
		xml_opt:add_child_node( get_label_path("email"), mysql_opt:get_query_result(i, "email"), p)
		xml_opt:add_child_node( get_label_path("fax"), mysql_opt:get_query_result(i, "fax"), p)
		xml_opt:add_child_node( get_label_path("memo"), mysql_opt:get_query_result(i, "memo"), p)
		xml_opt:add_child_node( get_label_path("handle_result"), mysql_opt:get_query_result(i, "handle_result"), p)
		xml_opt:add_child_node( get_label_path("handle_user_id"), mysql_opt:get_query_result(i, "handle_user_id"), p)
		xml_opt:add_child_node( get_label_path("handle_time"), mysql_opt:get_query_result(i, "handle_time"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


------------------------------------------------------------------------------
--
--	get app list release out by user 
--	new ver: 603
--	old ver: 0x55
------------------------------------------------------------------------------
eims_get_user_release_apps = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))

	local sql = "select id,name,application_type_id,fees,version,is_commend,state,`order`,url_target_new,is_auto_install,is_private,is_system,"
		  sql = sql.."is_show_on_desk,install_count,all_user_count from t_applications where user_id = "..eims_safety(userid).." order by `id`"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local app = get_label_path("app")
	local apps = app.."s"
	xml_opt:add_child_node(apps, "", data)
	local rowcount = mysql_opt:get_row_count()
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(app..tostring(i), "", data.."/"..apps)
		local p = data.."/"..apps.."/"..app..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
		xml_opt:add_child_node( get_label_path("app_type_id"), mysql_opt:get_query_result(i, "application_type_id"), p)
		xml_opt:add_child_node( get_label_path("fees"), mysql_opt:get_query_result(i, "fees"), p)
		xml_opt:add_child_node( get_label_path("version"), mysql_opt:get_query_result(i, "version"), p)
		xml_opt:add_child_node( get_label_path("is_commend"), mysql_opt:get_query_result(i, "is_commend"), p)
		xml_opt:add_child_node( get_label_path("state"), mysql_opt:get_query_result(i, "state"), p)
		xml_opt:add_child_node( get_label_path("order"), mysql_opt:get_query_result(i, "order"), p)
		xml_opt:add_child_node( get_label_path("url_target_new"), mysql_opt:get_query_result(i, "url_target_new"), p)
		xml_opt:add_child_node( get_label_path("is_auto_install"), mysql_opt:get_query_result(i, "is_auto_install"), p)
		xml_opt:add_child_node( get_label_path("is_private"), mysql_opt:get_query_result(i, "is_private"), p)
		xml_opt:add_child_node( get_label_path("is_system"), mysql_opt:get_query_result(i, "is_system"), p)
		xml_opt:add_child_node( get_label_path("is_show_on_desk"), mysql_opt:get_query_result(i, "is_show_on_desk"), p)
		xml_opt:add_child_node( get_label_path("install_count"), mysql_opt:get_query_result(i, "install_count"), p)
		xml_opt:add_child_node( get_label_path("all_user_count"), mysql_opt:get_query_result(i, "all_user_count"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


------------------------------------------------------------------------------
--
--	get user's all apps
--	new ver: 609
--	old ver: 0x68
------------------------------------------------------------------------------
eims_get_user_all_apps = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local sql = "select t_sites.id, t_sites.name, t_applications.id as application_id, t_applications.`name` as application_name, t_application_types.`name` "
		  sql = sql.."as application_type, t_applications.create_time ,t_applications.state, t_sites.owner_id, (select (1) from t_user_in_sitegroup where group_id "
		  sql = sql.."in (select group_id from t_site_user_id_list where group_id > -1 and t_site_user_id_list.site_id = t_sites.id)) as user_count_in_group ,"
		  sql = sql.."(select count(1) from t_site_user_id_list where (t_site_user_id_list.site_id = t_sites.id and t_site_user_id_list.group_id = -1)) "
		  sql = sql.."as user_count_in_site  from t_sites JOIN t_applications on t_sites.application_id = t_applications.id and t_sites.owner_id = "..eims_safety(userid)
		  sql = sql.." and t_sites.is_deleted = 0 JOIN t_application_types ON t_applications.application_type_id = t_application_types.id;"

	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local app = get_label_path("app")
	local apps = app.."s"
	xml_opt:add_child_node(apps, "", data)
	local rowcount = mysql_opt:get_row_count()
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(app..tostring(i), "", data.."/"..apps)
		local p = data.."/"..apps.."/"..app..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
		xml_opt:add_child_node( get_label_path("create_time"), mysql_opt:get_query_result(i, "create_time"), p)
		xml_opt:add_child_node( get_label_path("app_id"), mysql_opt:get_query_result(i, "application_id"), p)
		xml_opt:add_child_node( get_label_path("app_name"), mysql_opt:get_query_result(i, "application_name"), p)
		xml_opt:add_child_node( get_label_path("owner_id"), mysql_opt:get_query_result(i, "owner_id"), p)
		xml_opt:add_child_node( get_label_path("state"), mysql_opt:get_query_result(i, "state"), p)
		xml_opt:add_child_node( get_label_path("user_count_in_group"), mysql_opt:get_query_result(i, "user_count_in_group"), p)
		xml_opt:add_child_node( get_label_path("user_count_in_site"), mysql_opt:get_query_result(i, "user_count_in_site"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


------------------------------------------------------------------------------
--
--
------------------------------------------------------------------------------
eims_check_user_is_apps_private = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local appid = xml_opt:get_node_value(get_label_path("data", "app_id"))
end


------------------------------------------------------------------------------
--
--	new
--	ole ver: 0x45
------------------------------------------------------------------------------
eims_get_user_private_app_list = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local sql = "select application_id from t_app_private_user_id_list where user_id = "..eims_safety(userid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local rowcount = mysql_opt:get_row_count()
	--if rowcount <= 0 then
	--	return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "没有找到应用列表")
	--end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local app = get_label_path("app")
	local apps = app.."s"
	xml_opt:add_child_node(apps, "", data)
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(app..tostring(i), "", data.."/"..apps)
		local p = data.."/"..apps.."/"..app..tostring(i)
		xml_opt:add_child_node( get_label_path("app_id"), mysql_opt:get_query_result(i, "application_id"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


--------------------------------------------------------
--
--	register
--	new ver:
--	old ver: 0x11
--------------------------------------------------------
eims_create_app_user = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local name = xml_opt:get_node_value(get_label_path("data", "name"))
	local createid = xml_opt:get_node_value(get_label_path("data", "creater_id"))
	local pwd = xml_opt:get_node_value(get_label_path("data", "password"))
	local comname = xml_opt:get_node_value(get_label_path("data", "company_name"))
	local email = xml_opt:get_node_value(get_label_path("data", "email"))
	local tel = xml_opt:get_node_value(get_label_path("data", "telephone"))
	local mobile = xml_opt:get_node_value(get_label_path("data", "mobile"))
	local gender = xml_opt:get_node_value(get_label_path("data", "gender"))
	local shortcomname = xml_opt:get_node_value(get_label_path("data", "short_company_name"))
	local homeaddr = xml_opt:get_node_value(get_label_path("data", "home_addr"))
	local officetel = xml_opt:get_node_value(get_label_path("data", "office_tel"))
	local fax = xml_opt:get_node_value(get_label_path("data", "fax"))

	local sql = "select `soft_owner_id`,`soft_type` from t_users where `id` = "..eims_safety(createid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local rowc = mysql_opt:get_row_count()
	if rowc <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "创建者不存在")
	end

	local softownerid = mysql_opt:get_query_result(0, "soft_owner_id")
	local softtype = mysql_opt:get_query_result(0, "soft_type")
	mysql_opt:release_res()

	sql = "select 1 from t_users where email = '"..eims_safety(email).."'"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	rowc = mysql_opt:get_row_count()
	if rowc  > 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "邮箱不存在")
	end
	mysql_opt:release_res()

	sql = "select id from t_users where mobile = '"..eims_safety(mobile).."'"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	rowc = mysql_opt:get_row_count()
	if rowc > 0 then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "手机号码不存在")
	end
	mysql_opt:release_res()

	local md5pwd = tool:handlePassword(pwd)
	local key = tool:get_des_key()
	while true do
		sql = "insert into t_users (name, password, register_time, company_name, email, telephone, mobile, soft_type, default_identity, "
		sql = sql.."soft_owner_id, sex, short_company_name, home_address, office_telephone, fax_number, creater_id, `key`) values "
		sql = sql.."('"..eims_safety(name).."', '"..eims_safety(md5pwd).."', now(), '"..eims_safety(comname).."', '"..eims_safety(email).."', '"..eims_safety(tel)
		sql = sql.."', '"..eims_safety(mobile).."', "..eims_safety(softtype)..", 2, "..eims_safety(softownerid)
		sql = sql..", "..eims_safety(gender)..", '"..eims_safety(shortcomname).."', '"..eims_safety(homeaddr).."', '"..eims_safety(officetel).."', '"..eims_safety(fax).."', "..eims_safety(createid)..", '"..eims_safety(key).."')"
		result = mysql_opt:oper_db_trans_exc_v2(sql, false)
		if result < 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
		if is_beautiful(result) == true then
			local reservedpwd = tool:get_rand_num(6)
			sql = "update t_users set `creater_id` = 10001, `email` = '"..reservedpwd.."@eims.com.cn', `password` = '"..tool:handlePassword(reservedpwd).."',`default_identity` = 1, "
			sql = sql.."`soft_owner_id` = "..tostring(math.floor(result))..", `name` = 'reserved', `reality_name` = 'reserved', `company_name` = '深圳英迈思文化科技有限公司' where `id` = "..tostring(math.floor(result))
			result = mysql_opt:oper_db_trans_exc_v2(sql, false)
			if result < 0 then
				logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
				return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
			end
		else
			break
		end
	end
	

	local newid = result

	sql = "update t_users set soft_user_id = "..newid..", site_owner_id = "..newid.." where `id` = "..newid
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "update t_applications set `all_user_count` = (ifnull(`all_user_count`, 0) + 1) where `is_auto_install` = 1 or `is_system` = 1"
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "insert into t_site_user_id_list(`site_id`,`user_id`,`is_allow_design`,`is_allow_edit_data`,`group_id`,`optioner_id`) "
	sql = sql.."values (3040, "..newid..", 1, 1, -1, 10001)"
	result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	xml_opt:add_child_node(get_label_path("soft_user_id"), tostring(math.floor(newid)), get_label_path("data"))
	return xml_opt:create_xml_string()

end

--------------------------------------------------------
--
--	register
--	new ver:
--	old ver: create_applications_private_list
--------------------------------------------------------
eims_add_app_auth = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local appid = xml_opt:get_node_value(get_label_path("data", "app_id"))
	local optionerid = xml_opt:get_node_value(get_label_path("data", "optioner_id"))

	local sql = "select count(id) from t_users where `id` in ("..eims_safety(userid)..", "..eims_safety(optionerid)..")"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end
	mysql_opt:release_res()

	sql = "select * from t_applications where `id` = "..eims_safety(appid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "应用不存在")
	end
	mysql_opt:release_res()

	sql = "insert into t_app_private_user_id_list(`application_id`, `user_id`, `optioner_id`, `create_time`) "
	sql = sql.."values("..eims_safety(appid)..", "..eims_safety(userid)..", "..eims_safety(optionerid)..", now())"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end

--------------------------------------------------------
--
--	register
--	new ver:
--	old ver: 0x6F
--------------------------------------------------------
eims_get_app_private_users = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local appid = xml_opt:get_node_value(get_label_path("data", "app_id"))

	local sql = "select application_id, user_id from t_app_private_user_id_list where user_id = "..eims_safety(userid).." and application_id = "..eims_safety(appid)
	--print(sql)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户或应用不存在")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local user = get_label_path("user")
	local users = user.."s"
	xml_opt:add_child_node(users, "", data)
	for i = 0, rowcount - 1 do
		local p = data.."/"..users.."/"..user..tostring(i)
		xml_opt:add_child_node(user..tostring(i), "", data.."/"..users)
		xml_opt:add_child_node(get_label_path("app_id"), mysql_opt:get_query_result(i, "application_id"), p)
		xml_opt:add_child_node(get_label_path("user_id"), mysql_opt:get_query_result(i, "user_id"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


--------------------------------------------------------
--
--	register
--	new ver:
--	old ver: 0x10
--------------------------------------------------------
eims_create_soft_owner = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local name = xml_opt:get_node_value(get_label_path("data", "name"))
	local softtype = xml_opt:get_node_value(get_label_path("data", "soft_type"))
	local pwd = xml_opt:get_node_value(get_label_path("data", "password"))
	local comname = xml_opt:get_node_value(get_label_path("data", "company_name"))
	local email = xml_opt:get_node_value(get_label_path("data", "email"))
	local tel = xml_opt:get_node_value(get_label_path("data", "tel"))
	local mobile = xml_opt:get_node_value(get_label_path("data", "mobile"))
	local gender = xml_opt:get_node_value(get_label_path("data", "gender"))
	local shortcomname = xml_opt:get_node_value(get_label_path("data", "short_com_name"))
	local homeaddr = xml_opt:get_node_value(get_label_path("data", "home_addr"))
	local officetel = xml_opt:get_node_value(get_label_path("data", "office_tel"))
	local fax = xml_opt:get_node_value(get_label_path("data", "fax"))

	local sql = "select id from t_users where email = '"..eims_safety(email).."'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() > 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "邮箱已经被注册")
	end
	mysql_opt:release_res()

	sql = "select id from t_users where mobile = '"..eims_safety(mobile).."'"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() > 0 then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "手机号已经被注册")
	end
	mysql_opt:release_res()

	local md5pwd = tool:handlePassword(pwd)
	local key = tool:get_des_key()
	while true do
		sql = "insert into t_users (name, password, register_time, company_name, email, telephone, mobile, soft_type, default_identity, soft_owner_id, sex, "--
		sql = sql.."short_company_name, home_address, office_telephone, fax_number, creater_id, `key`) values ('"..eims_safety(name).."', '"..eims_safety(md5pwd).."', now(), '"..eims_safety(comname).."','"
		sql = sql..eims_safety(email).."', '"..eims_safety(tel).."', '"..eims_safety(mobile).."', "..eims_safety(softtype)..", 2, 10001, "..eims_safety(gender)..", '"..eims_safety(shortcomname).."', '"
		sql = sql..eims_safety(homeaddr).."', '"..eims_safety(officetel).."', '"..eims_safety(fax).."', 10001, '"..eims_safety(key).."')"
		result = mysql_opt:oper_db_trans_exc_v2(sql, false)
		if result < 0 then
			mysql_opt:rollback()
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
		if is_beautiful(result) == true then
			local reservedpwd = tool:get_rand_num(6)
			sql = "update t_users set `creater_id` = 10001, `email` = '"..reservedpwd.."@eims.com.cn', `password` = '"..tool:handlePassword(reservedpwd).."',`default_identity` = 1, "
			sql = sql.."`soft_owner_id` = "..tostring(math.floor(result))..", `name` = 'reserved', `reality_name` = 'reserved', `company_name` = '深圳英迈思文化科技有限公司' where `id` = "..tostring(math.floor(result))
			result = mysql_opt:oper_db_trans_exc_v2(sql, false)
			if result < 0 then
				logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
				return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
			end
		else
			break
		end
	end

	local newid = result

	sql = "update t_users set soft_owner_id = 10001, soft_user_id = 10001, site_owner_id = 10001 where `id` = 10001"
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		mysql_opt:rollback()
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local vcode = tool:get_rand_num(6)
	sql = "insert into t_email_verifying (user_id, email, verify_code, try_time) values ("..newid..", '"..eims_safety(email).."', '"..vcode.."', now())"
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		mysql_opt:rollback()
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local subject = "尊敬的犀牛云用户，您好！您在犀牛云申请的犀牛账号激活码，请查收！"
    local body = "尊敬的犀牛云平台["
    body = body..name
    body = body.."]用户，您好：<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;您在犀牛云申请的犀牛账号激活码为 "
    body = body..vcode
    body = body.."，请及时登录平台输入此激活码进行激活！谢谢。"

    sql = "insert into t_send_emails (email, subject, body) values ('"..eims_safety(email).."', '"..subject.."', '"..eims_safety(body).."')"
    result = mysql_opt:oper_db_trans_exc_v2(sql, false)
    if result < 0 then
    	mysql_opt:rollback()
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
    end

    sql = "update t_applications set `all_user_count` = (ifnull(`all_user_count`, 0) + 1) where `is_auto_install` = 1 or `is_system` = 1"
    result = mysql_opt:oper_db_trans_exc_v2(sql, false)
    if result < 0 then
    	mysql_opt:rollback()
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
    end

    sql = "insert into t_site_user_id_list(`site_id`,`user_id`,`is_allow_design`,`is_allow_edit_data`,`group_id`,`optioner_id`) ";
    sql = sql.."values (3040, "..newid..", 1, 1, -1, 10001)"
    result = mysql_opt:oper_db_trans_exc_v2(sql, true)
    if result < 0 then
    	mysql_opt:rollback()
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
    end

    xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
    local dl = get_label_path("data")
    xml_opt:add_child_node(get_label_path("soft_owner_id"), tostring(math.floor(newid)), dl)

    return xml_opt:create_xml_string()
end

--------------------------------------------------------
--
--	register
--	new ver:
--	old ver: a part of login
--------------------------------------------------------
emis_get_all_app_id = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local sql = "select `id`, `install_count`, `all_user_count` from t_applications where state = 1"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local rowcount = mysql_opt:get_row_count()
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local dl = get_label_path("data")
	local app = get_label_path("app")
	local apps = app.."s"
	xml_opt:add_child_node(apps, "", dl)
	for i = 0, rowcount - 1 do
		local p = dl.."/"..apps.."/"..app..tostring(i)
		xml_opt:add_child_node(app..tostring(i), "", dl.."/"..apps)
		xml_opt:add_child_node(get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node(get_label_path("install_count"), mysql_opt:get_query_result(i, "install_count"), p)
		xml_opt:add_child_node(get_label_path("all_user_count"), mysql_opt:get_query_result(i, "all_user_count"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

--------------------------------------------------------
--
--	register
--	new ver:
--	old ver: a part of login
--------------------------------------------------------
eims_get_all_app_type_id = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local sql = "select `id` from t_application_types"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local rowcount = mysql_opt:get_row_count()
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local dl = get_label_path("data")
	local at = get_label_path("app_type")
	local ats = at.."s"
	xml_opt:add_child_node(ats, "", dl)
	for i = 0, rowcount - 1 do
		local p = dl.."/"..ats.."/"..at..tostring(i)
		xml_opt:add_child_node(at..tostring(i), "", dl.."/"..ats)
		xml_opt:add_child_node(get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

--------------------------------------------------------
--
--	register
--	new ver:
--	old ver: a part of heart beat
--------------------------------------------------------
eims_get_app_types = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local dv = xml_opt:get_node_value(get_label_path("data", "data_ver"))
	local sql = "select * from t_application_types where data_version > '"..eims_safety(dv).."' order by `id`"
    local result = mysql_opt:oper_db(sql)
    if result ~= 0 then
    	logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
    end

    local rowcount = mysql_opt:get_row_count()
    xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
    local at = get_label_path("app_type")
    local dl = get_label_path("data")
    local ats = at.."s"
    xml_opt:add_child_node(ats, "", dl)
    for i = 0, rowcount do
        local p = dl.."/"..ats.."/"..at..tostring(i)
        xml_opt:add_child_node(at..tostring(i), "", dl.."/"..ats)
        xml_opt:add_child_node(get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
        xml_opt:add_child_node(get_label_path("parent_id"), mysql_opt:get_query_result(i, "parent_id"), p)
        xml_opt:add_child_node(get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
        xml_opt:add_child_node(get_label_path("code"), mysql_opt:get_query_result(i, "code"), p)
        xml_opt:add_child_node(get_label_path("description"), mysql_opt:get_query_result(i, "description"), p)
        xml_opt:add_child_node(get_label_path("order"), mysql_opt:get_query_result(i, "order"), p)
        xml_opt:add_child_node(get_label_path("is_use"), mysql_opt:get_query_result(i, "is_use"), p)
        xml_opt:add_child_node(get_label_path("data_ver"), mysql_opt:get_query_result(i, "data_version"), p)
    end
    mysql_opt:release_res()
    
    return xml_opt:create_xml_string()
end
