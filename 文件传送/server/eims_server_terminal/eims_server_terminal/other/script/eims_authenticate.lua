-----------------------------------------------------------------
--	
--	
--
-----------------------------------------------------------------

package.path = package.path ..";./?.lua;../other/script/?.lua;./script/?.lua"

require("eims_log")
require("eims_error")
require("eims_common")
require("eims_message")

----------------------------------------------------------
--	login message handle
----------------------------------------------------------

eims_login = function(xml_opt, mysql_opt)
	local id, ver, instruction, sign = eims_get_message_base_element( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local password = xml_opt:get_node_value(get_label_path("data", "password"))
	local ip = xml_opt:get_node_value(get_label_path("data", "ip"))
	--local mobile = xml_opt:get_node_value(get_label_path("data", "mobile"))
	local place = xml_opt:get_node_value(get_label_path("data", "place"))
	local clientid = xml_opt:get_node_value(get_label_path("data", "client_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))

	local sql = "select id,is_online,login_count,password,is_allow_login,name,reality_name,is_actived,last_login_time,last_login_ip,"
		  sql = sql.."register_time,default_identity,soft_type,soft_owner_id,soft_user_id,site_owner_id,company_name,email,email_verified,"
		  sql = sql.."telephone,mobile,mobile_verified,id_card_number,address, postcode,ukey from t_users where `id` = " ..eims_safety(userid).." and is_erased = 0"
	local ret = mysql_opt:oper_db(sql)
	if(ret ~= 0) then 
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local count = mysql_opt:get_row_count()
	if(tonumber(count) <= 0) then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end
	local isallowlogin = mysql_opt:get_query_byte_result(0, "is_allow_login")
	local logincount = mysql_opt:get_query_result(0, "login_count")
	local name = mysql_opt:get_query_result(0, "name")
	local realityname = mysql_opt:get_query_result(0, "reality_name")
	local isactived = mysql_opt:get_query_byte_result(0, "is_actived")
	local lastlogintime = mysql_opt:get_query_result(0, "last_login_time")
	local lastloginip = mysql_opt:get_query_result(0, "last_login_ip")
	local registertime = mysql_opt:get_query_result(0, "register_time")
	local defaultidentity = mysql_opt:get_query_result(0, "default_identity")
	local softtype = mysql_opt:get_query_result(0, "soft_type")
	local softownerid = mysql_opt:get_query_result(0, "soft_owner_id")
	local softuserid = mysql_opt:get_query_result(0, "soft_user_id")
	local siteownerid = mysql_opt:get_query_result(0, "site_owner_id")
	local companyname = mysql_opt:get_query_result(0, "company_name")
	local email = mysql_opt:get_query_result(0, "email")
	local emailverified = mysql_opt:get_query_byte_result(0, "email_verified")
	local tel = mysql_opt:get_query_result(0, "telephone")
	local mb = mysql_opt:get_query_result(0, "mobile")
	local mv = mysql_opt:get_query_byte_result(0, "mobile_verified")
	local idnum = mysql_opt:get_query_result(0, "id_card_number")
	local addr = mysql_opt:get_query_result(0, "address")
	local postcode = mysql_opt:get_query_result(0, "postcode")
	local ukey = mysql_opt:get_query_result(0, "ukey")

	local web_login_err = true
	if isallowlogin == "0" then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不允许登陆")
	end

	if tonumber(siteid) > 0 then
		sql = "select id from t_sites where owner_id = "..eims_safety(userid).." and `id` = "..eims_safety(siteid)
		if mysql_opt:oper_db(sql) ~= 0 then
			logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
		if mysql_opt:get_row_count() <= 0 then
			sql = "select id from t_user_in_sitegroup where `user_id` = "..eims_safety(userid).." and site_id = "..eims_safety(siteid)
			if mysql_opt:oper_db(sql) ~= 0 then
				logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
				return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
			end
			if mysql_opt:get_row_count() <= 0 then
				sql = "select id from t_site_user_id_list where `user_id` = "..eims_safety(userid).." and site_id = "..eims_safety(siteid)
				if mysql_opt:oper_db(sql) < 0 then
					logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
					return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
				end
				if mysql:get_row_count() <= 0 then
					web_login_err = true
				else
					web_login_err = false
				end
			end
		else
			web_login_err = false
		end
	end

	local user_pwd = mysql_opt:get_query_result(0, "password")
	mysql_opt:release_res()

	-- pwd error
	if user_pwd ~= tool:handlePassword(password) then
		mysql_opt:release_res()
		sql = "insert into t_login_logout_events (user_id, event_type, ip, site_id, place) values ("..eims_safety(userid)..", 3, '"..eims_safety(ip).."', "..eims_safety(siteid)..", '"..place.."')"
		if mysql_opt:oper_db(sql) ~= 0 then
			logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		end
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "密码错误")
	end
	

	-- no auth
	if web_login_err == true and siteid ~= "-3" then
		sql = "insert into t_login_logout_events (user_id, event_type, ip, site_id, place) values ("..eims_safety(userid)..", 3, '"..eims_safety(ip).."', "..eims_safety(siteid)..", '"..place.."')"
		if mysql_opt:oper_db(sql) ~= 0 then
			logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "没有权限管理此网站")
	end


	-- get all sites
	sql = "select id from t_sites where is_deleted = 0 and (owner_id = "..eims_safety(userid).." or creater_id = "..eims_safety(userid)..") order by `id`"
	if mysql_opt:oper_db(sql) ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local sa = get_label_path("site_all")
	local sas = sa.."s"
	xml_opt:add_child_node(sas, "", data)
	local rowcount = mysql_opt:get_row_count()
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(sa..tostring(i), "", data.."/"..sas)
		local p = data.."/"..sas.."/"..sa..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
	end

	-- get all sites using
	sql = "select a.id from t_sites as a, (select * from t_site_user_id_list where ((user_id = "..eims_safety(userid).." and (group_id = -1)) or group_id = -3 or group_id in (select group_id from t_user_in_sitegroup where user_id = "..eims_safety(userid).."))) as b where a.is_deleted = 0 and a.`id` = b.site_id order by `id`"
	if mysql_opt:oper_db(sql) ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	data = get_label_path("data")
	local su = get_label_path("site_use")
	local sus = su.."s"
	xml_opt:add_child_node(sus, "", data)
	local rowcount = mysql_opt:get_row_count()
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(su..tostring(i), "", data.."/"..sus)
		local p = data.."/"..sus.."/"..su..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
	end

	-- get all app
	sql = "select `id`, `install_count`, `all_user_count` from t_applications where state = 1"
	if mysql_opt:oper_db(sql) ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	data = get_label_path("data")
	local aa = get_label_path("app_all")
	local aas = aa.."s"
	xml_opt:add_child_node(aas, "", data)
	local rowcount = mysql_opt:get_row_count()
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(aa..tostring(i), "", data.."/"..aas)
		local p = data.."/"..aas.."/"..aa..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("install_count"), mysql_opt:get_query_result(i, "install_count"), p)
		xml_opt:add_child_node( get_label_path("all_user_count"), mysql_opt:get_query_result(i, "all_user_count"), p)
	end

	-- get app type
	sql = "select `id` from t_application_types"
	if mysql_opt:oper_db(sql) ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	data = get_label_path("data")
	local at = get_label_path("app_type")
	local ats = at.."s"
	xml_opt:add_child_node(ats, "", data)
	local rowcount = mysql_opt:get_row_count()
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(at..tostring(i), "", data.."/"..ats)
		local p = data.."/"..ats.."/"..at..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
	end

	-- get notify type
	sql = "select `id` from t_notify_type"
	if mysql_opt:oper_db(sql) ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	data = get_label_path("data")
	local nt = get_label_path("notify_type")
	local nts = nt.."s"
	xml_opt:add_child_node(nts, "", data)
	local rowcount = mysql_opt:get_row_count()
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(nt..tostring(i), "", data.."/"..nts)
		local p = data.."/"..nts.."/"..nt..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
	end

	-- update state
	local lc = tonumber(logincount) + 1
	--print("ip is "..ip)
	sql = "update t_users set last_login_time = now(), last_login_ip = '"..eims_safety(ip).."', login_count = "..tostring(lc)..", is_online = 1 where `id` = "..eims_safety(userid)

	if mysql_opt:oper_db_trans_exc_v2(sql, false) < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	--add event
	sql = "insert into t_login_logout_events (user_id, event_type, ip, site_id, place) values ("..eims_safety(userid)..", 3 , '"..eims_safety(ip).."', 0, '"..eims_safety(place).."')"
	--print(event_sql)
	if mysql_opt:oper_db_trans_exc_v2(sql, false) < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "update t_users_online set user_id = "..eims_safety(userid)..",oper_time=now() where unique_id ="..eims_safety(clientid)
	
	if mysql_opt:oper_db_trans_exc_v2(sql, true) < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local dt = get_label_path("data")
	xml_opt:add_child_node(get_label_path("user_id"), userid, dt)
	xml_opt:add_child_node(get_label_path("is_allow_login"), isallowlogin, dt)
	xml_opt:add_child_node(get_label_path("login_count"), logincount, dt)
	xml_opt:add_child_node(get_label_path("name"), name, dt)
	xml_opt:add_child_node(get_label_path("reality_name"), realityname, dt)
	xml_opt:add_child_node(get_label_path("is_actived"), isactived, dt)
	xml_opt:add_child_node(get_label_path("last_login_time"), lastlogintime, dt)
	xml_opt:add_child_node(get_label_path("last_login_ip"), lastloginip, dt)
	xml_opt:add_child_node(get_label_path("register_time"), registertime, dt)
	xml_opt:add_child_node(get_label_path("default_identity"), defaultidentity, dt)
	xml_opt:add_child_node(get_label_path("soft_type"), softtype, dt)
	xml_opt:add_child_node(get_label_path("soft_owner_id"), softownerid, dt)
	xml_opt:add_child_node(get_label_path("soft_user_id"), softuserid, dt)
	xml_opt:add_child_node(get_label_path("site_owner_id"), siteownerid, dt)
	xml_opt:add_child_node(get_label_path("company_name"), companyname, dt)
	xml_opt:add_child_node(get_label_path("email"), email, dt)
	xml_opt:add_child_node(get_label_path("email_verified"), emailverified, dt)
	xml_opt:add_child_node(get_label_path("telephone"), tel, dt)
	xml_opt:add_child_node(get_label_path("mobile"), mb, dt)
	xml_opt:add_child_node(get_label_path("mobile_verified"), mv, dt)
	xml_opt:add_child_node(get_label_path("id_card_number"), idnum, dt)
	xml_opt:add_child_node(get_label_path("address"), addr, dt)
	xml_opt:add_child_node(get_label_path("postcode"), postcode, dt)
	xml_opt:add_child_node(get_label_path("ukey"), ukey, dt)



	return xml_opt:create_xml_string()
end

-------
--logout func

eims_logout = function(xml_opt, mysql_opt)--, xml_data)
	
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local clientid = xml_opt:get_node_value(get_label_path("data", "client_id"))
	local ip = xml_opt:get_node_value(get_label_path("data", "ip"))
	local place = xml_opt:get_node_value(get_label_path("data", "place"))

	local sql = "update t_users set is_online = 0 where `id` = "..eims_safety(userid)
	if mysql_opt:oper_db_trans_exc_v2(sql, false) < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "insert into t_login_logout_events (user_id, event_type, ip, site_id, place) values ("..eims_safety(userid)..", 3 , '"..eims_safety(ip).."', 0, '"..eims_safety(place).."')"

	if mysql_opt:oper_db_trans_exc_v2(sql, false) < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "delete from t_users_online where unique_id = "..eims_safety(clientid)
	if mysql_opt:oper_db_trans_exc_v2(sql, true) < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	xml_opt:add_child_node(get_label_path("user_id"), userid, get_label_path("data"))

	return xml_opt:create_xml_string()
end

----------------------------------------------------------------------
--
--	delete auth group
--
----------------------------------------------------------------------
eims_delete_auth_group = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local optionerid = xml_opt:get_node_value(get_label_path("data", "optioner_id"))
	local groupid = xml_opt:get_node_value(get_label_path("data", "group_id"))

	local sql = "select id from t_user_in_sitegroup where group_id in ("..eims_safety(groupid)..")"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	if mysql_opt:get_row_count() > 0 then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "该权限组还有用户，不允许被删除")
	end
	mysql_opt:release_res()
	sql = "select id from t_site_group where id = "..eims_safety(groupid).." and user_id = "..eims_safety(optionerid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "该权限组不存在或没有权限")
	end
	mysql_opt:release_res()

	sql = "delete from t_site_group where id = "..eims_safety(groupid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "delete from t_user_in_sitegroup where group_id = "..eims_safety(groupid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "delete from t_group_application_instances where group_id = "..eims_safety(groupid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "delete from t_site_user_id_list where group_id <> -1 and group_id = "..eims_safety(groupid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")

	return xml_opt:create_xml_string()

end


eims_get_all_group_by_site = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local sql = "select *,(select count(1) from t_user_in_sitegroup where group_id = t_site_group.id) as menber_counts,(select `name` from t_sites where id = "..eims_safety(siteid)..") "
	sql = sql.."as site_name from t_site_group where id in (select group_id from t_site_user_id_list where site_id = "..eims_safety(siteid).." and group_id > -1) "
	sql = sql.."union select *,(select count(1) from t_user_in_sitegroup where group_id = t_site_group.id) as menber_counts ,('无') as site_name from t_site_group "
	sql = sql.."where site_id = "..eims_safety(siteid).." and id not in (select group_id from t_site_user_id_list where group_id > -1)"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local rowcount = mysql_opt:get_row_count()
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local group = get_label_path("group")
	local groups = group.."s"
	xml_opt:add_child_node(groups, "", data)
	for i = 0, rowcount -1 do
		xml_opt:add_child_node(group..tostring(i), "", data.."/"..groups)
		local p = data.."/"..groups.."/"..group..tostring(i)
		xml_opt:add_child_node(get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node(get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
		xml_opt:add_child_node(get_label_path("menber_counts"), mysql_opt:get_query_result(i, "menber_counts"), p)
		xml_opt:add_child_node(get_label_path("site_id"), mysql_opt:get_query_result(i, "site_id"), p)
		xml_opt:add_child_node(get_label_path("description"), mysql_opt:get_query_result(i, "description"), p)
		xml_opt:add_child_node(get_label_path("user_id"), mysql_opt:get_query_result(i, "user_id"), p)
		xml_opt:add_child_node(get_label_path("create_date"), mysql_opt:get_query_result(i, "create_date"), p)
		xml_opt:add_child_node(get_label_path("site_name"), mysql_opt:get_query_result(i, "site_name"), p)
	end
	mysql_opt:release_res()
	return xml_opt:create_xml_string()

end


eims_add_application_instances = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local groupid = xml_opt:get_node_value(get_label_path("data", "group_id"))
	--print(groupid)
	local optionerid = xml_opt:get_node_value(get_label_path("data", "optioner_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))

	local sql = "select id from t_site_group where id = "..eims_safety(groupid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "该权限组不存在")
	end
	mysql_opt:release_res()

	sql = "select id from v_sites where owner_id = "..eims_safety(optionerid).." and `id` = "..eims_safety(siteid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点或应用不存在")
	end
	mysql_opt:release_res()

	sql = "select id from t_site_user_id_list where group_id = "..eims_safety(groupid).." and site_id = "..eims_safety(siteid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() > 0 then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "该站点已经被授权")
	end
	mysql_opt:release_res()

	sql = "insert into t_site_user_id_list (site_id, user_id, is_allow_design, is_allow_edit_data, create_date,group_id) "
	sql = sql.."values ("..eims_safety(siteid)..", "..eims_safety(optionerid)..", 1, 1, now(), "..eims_safety(groupid)..")"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()

end

eims_edit_group_information_by_group_id = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local groupname = xml_opt:get_node_value(get_label_path("data", "group_name"))
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local desc = xml_opt:get_node_value(get_label_path("data", "desc"))
	local groupid = xml_opt:get_node_value(get_label_path("data", "group_id"))

	local sql = "select id from t_site_group where id = "..eims_safety(groupid).." and user_id = "..eims_safety(userid)
	--print(sql)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "权限组不存在或没有权限")
	end
	mysql_opt:release_res()

	sql = "update t_site_group set name = '"..eims_safety(groupname).."', description = '"..eims_safety(desc).."' where id = "..eims_safety(groupid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end


eims_add_user_in_site_group = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local groupid = xml_opt:get_node_value(get_label_path("data", "group_id"))
	local optionerid = xml_opt:get_node_value(get_label_path("data", "optioner_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))

	local sql = "select id from t_users where id = "..eims_safety(userid).." or `mobile` = "..eims_safety(userid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end
	mysql_opt:release_res()

	sql = "select id from t_site_group where id = "..eims_safety(groupid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "该权限组不存在")
	end
	mysql_opt:release_res()

	--sql = "select id from v_sites where owner_id = "..optionerid.." and `id` = "..siteid
	--result = mysql_opt:oper_db(sql)
	--if result ~= 0 then
	--	logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
	--	return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "server error")
	--end

	--if mysql_opt:get_row_count() <= 0 then
	--	return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "user not owner")
	--end

	--sql = "select id from t_site_user_id_list where `group_id` = "..groupid.." and site_id = "..siteid

	sql = "select 1 from t_user_in_sitegroup where user_id = "..eims_safety(userid).." and group_id = "..eims_safety(groupid).." and site_id = "..eims_safety(siteid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	if mysql_opt:get_row_count() > 0 then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "此用户已经在该权限组中")
	end

	sql = "insert into t_user_in_sitegroup (site_id, user_id, group_id, optioner_id, create_date) "
	sql = sql.."values ("..eims_safety(siteid)..", "..eims_safety(userid)..", "..eims_safety(groupid)..", "..eims_safety(optionerid)..", now())"
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		mysql_opt:rollback()
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "update t_site_user_id_list set data_version = now() where group_id = "..eims_safety(groupid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end


eims_delete_user_in_site_group = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local groupid = xml_opt:get_node_value(get_label_path("data", "group_id"))
	local optionerid = xml_opt:get_node_value(get_label_path("data", "optioner_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))

	local sql = "select id from t_user_in_sitegroup where group_id = "..eims_safety(groupid).." and site_id = "..eims_safety(siteid).." and user_id = "..eims_safety(userid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "权限组中不存在该用户")
	end
	mysql_opt:release_res()

	sql = "delete from t_user_in_sitegroup where group_id = "..eims_safety(groupid).." and site_id = "..eims_safety(siteid).." and user_id = "..eims_safety(userid)
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	sql = "delete from t_site_user_id_list where site_id = "..eims_safety(siteid).." and user_id = "..eims_safety(userid).." and group_id = -1"
	result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end

eims_set_group_or_user_role = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userorgroupid = xml_opt:get_node_value(get_label_path("data", "user_or_group_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local settype = xml_opt:get_node_value(get_label_path("data", "set_type"))
	local role = xml_opt:get_node_value(get_label_path("data", "role"))

	local sql = ""
	if settype == "0" then
		sql = "select id from t_site_user_id_list where user_id ="..eims_safety(userorgroupid).." and site_id="..eims_safety(siteid)
	else
		if settype == "1" then
			sql = "select id from t_group_application_instances where group_id ="..eims_safety(userorgroupid).." and site_id="..eims_safety(siteid)
		else
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "参数值错误，服务器拒绝响应")
		end
	end

	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	--if mysql_opt:get_row_count() <= 0 then
	--	return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "not found site or app")
	--end
	
	--result = mysql_opt:oper_db(sql)
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "没有权限管理此站点")
	end
	mysql_opt:release_res()

	if settype == "0" then
		--user
		sql = "update t_site_user_id_list set role = "..eims_safety(role).." where user_id = "..eims_safety(userorgroupid).." and site_id = "..eims_safety(siteid) 
	else 
		if settype == "1" then
		--group
		sql = "update t_group_application_instances set role = "..eims_safety(role).." where group_id = "..eims_safety(userorgroupid).." and site_id = "..eims_safety(siteid)
	else
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "参数值错误，服务器拒绝响应")
		end
	end
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()

end

eims_create_group_by_userid_and_siteid = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local siteid = xml_opt:get_node_value(get_label_path("data", "site_id"))
	local groupname = xml_opt:get_node_value(get_label_path("data", "site_group_name"))
	local groupdesc = xml_opt:get_node_value(get_label_path("data", "site_group_desc"))

	local sql = "select id from t_users where id = "..eims_safety(userid).." or `mobile` = '"..eims_safety(userid).."'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end
	mysql_opt:release_res()

	sql = "select id from v_sites where owner_id = "..eims_safety(userid).." and `id` = "..eims_safety(siteid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "站点不存在或没有权限")
	end
	mysql_opt:release_res()

	sql = "select 1 from t_site_group where name = '"..eims_safety(groupname).."' and user_id = "..eims_safety(userid).." and site_id = "..eims_safety(siteid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() > 0 then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "权限组名已经存在")
	end

	sql = "insert into t_site_group (name, description, site_id, user_id, create_date) "
	sql = sql.."values ('"..eims_safety(groupname).."', '"..eims_safety(groupdesc).."', "..eims_safety(siteid)..", "..eims_safety(userid)..", now())"
	result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result < 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	xml_opt:add_child_node(get_label_path("group_id"), tostring(math.floor(result)), get_label_path("data"))

	return xml_opt:create_xml_string()
end



