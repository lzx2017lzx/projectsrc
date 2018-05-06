--------------------------------------------------------------------
--
--	base services manager
--
--------------------------------------------------------------------

package.path = package.path ..";./?.lua;../other/script/?.lua;./script/?.lua"
require("eims_log")
require("eims_common")
require("eims_error")
require("eims_message")
--require("eims_usermgr")


---------------------------------------------
--
--	old: 0x40    获取最新的版本号, 下载 ftp 地址列表
--	new: 802
---------------------------------------------
eims_get_client_new_ver_and_path = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local curver = xml_opt:get_node_value(get_label_path("data", "cur_ver"))
	local sql = "select value from t_options where `key` = 'client_version'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "没有找到最新版本")
	end
	local newver = mysql_opt:get_query_result(0, "value")
	mysql_opt:release_res()

	sql = "select id,ftp_ip,ftp_port,ftp_username,ftp_password,update_filename,line_type from t_client_update_ftps order by `id`"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	rowcount = mysql_opt:get_row_count()
	local dl = get_label_path("data")

	xml_opt:add_child_node(get_label_path("newver"), newver, dl);

	local ftp = get_label_path("ftp")
	local ftps = ftp.."s"
	xml_opt:add_child_node(ftps, "", dl)
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(ftp..tostring(i), "", dl.."/"..ftps)
		local p = dl.."/"..ftps.."/"..ftp..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("ftp_ip"), mysql_opt:get_query_result(i, "ftp_ip"), p)
		xml_opt:add_child_node( get_label_path("ftp_port"), mysql_opt:get_query_result(i, "ftp_port"), p)
		xml_opt:add_child_node( get_label_path("ftp_username"), mysql_opt:get_query_result(i, "ftp_username"), p)
		xml_opt:add_child_node( get_label_path("ftp_password"), mysql_opt:get_query_result(i, "ftp_password"), p)
		xml_opt:add_child_node( get_label_path("update_filename"), mysql_opt:get_query_result(i, "update_filename"), p)
		xml_opt:add_child_node( get_label_path("line_type"), mysql_opt:get_query_result(i, "line_type"), p)
	end
	mysql_opt:release_res()
	return xml_opt:create_xml_string()
end


---------------------------------------------
--
--	old: 0x41    获取最新的版本号, 下载 ftp 地址列表 (2015/09/16 客户端版本与DB系统拆分)
--	new: 813
---------------------------------------------
eims_get_client_new_ver_and_path_db = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local curver = xml_opt:get_node_value(get_label_path("data", "cur_ver"))
	local sql = "select value from t_options where `key` = 'client_version'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "没有找到最新版本")
	end
	local newver = mysql_opt:get_query_result(0, "value")
	--if newver == curver then
	--	xml_opt:add_child_node( get_label_path("id"), newver, get_label_path("data"))
	--	mysql_opt:release_res()
	--	return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "当前已经是最新版本")
	--end
	mysql_opt:release_res()

	sql = "select id,ftp_ip,ftp_port,ftp_username,ftp_password,update_filename,line_type from t_client_update_ftps order by `id`"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	rowcount = mysql_opt:get_row_count()
	local dl = get_label_path("data")

	xml_opt:add_child_node(get_label_path("newver"), newver, dl);

	local ftp = get_label_path("ftp")
	local ftps = ftp.."s"
	xml_opt:add_child_node(ftps, "", dl)
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(ftp..tostring(i), "", dl.."/"..ftps)
		local p = dl.."/"..ftps.."/"..ftp..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("ftp_ip"), mysql_opt:get_query_result(i, "ftp_ip"), p)
		xml_opt:add_child_node( get_label_path("ftp_port"), mysql_opt:get_query_result(i, "ftp_port"), p)
		xml_opt:add_child_node( get_label_path("ftp_username"), mysql_opt:get_query_result(i, "ftp_username"), p)
		xml_opt:add_child_node( get_label_path("ftp_password"), mysql_opt:get_query_result(i, "ftp_password"), p)
		xml_opt:add_child_node( get_label_path("update_filename"), mysql_opt:get_query_result(i, "update_filename"), p)
		xml_opt:add_child_node( get_label_path("line_type"), mysql_opt:get_query_result(i, "line_type"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


---------------------------------------------
--
--	old: 0x42    获取网站行业表(原版 01 方法) and // 0x42    获取网站行业表 for heart beat
--	new: 803
---------------------------------------------
eims_get_trade_type_list = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local dataver = xml_opt:get_node_value(get_label_path("data", "data_ver"))
	local sql = "select * from t_trade_types where data_version > '"..eims_safety(dataver).."' order by `order`"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local rowcount = mysql_opt:get_row_count()
	local dl = get_label_path("data")
	local trade = get_label_path("trade")
	local trades = trade.."s"
	xml_opt:add_child_node(trades, "", dl)
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(trade..tostring(i), "", dl.."/"..trades)
		local p = dl.."/"..trades.."/"..trade..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("parent_id"), mysql_opt:get_query_result(i, "parent_id"), p)
		xml_opt:add_child_node( get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
		xml_opt:add_child_node( get_label_path("code"), mysql_opt:get_query_result(i, "code"), p)
		xml_opt:add_child_node( get_label_path("description"), mysql_opt:get_query_result(i, "description"), p)
		xml_opt:add_child_node( get_label_path("order"), mysql_opt:get_query_result(i, "order"), p)
		xml_opt:add_child_node( get_label_path("is_use"), mysql_opt:get_query_byte_result(i, "is_use"), p)
		xml_opt:add_child_node( get_label_path("data_ver"), mysql_opt:get_query_result(i, "data_version"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

------------------------------------------------------
--
--	获取最新控件类型列表 
--	old: 0x43
--	new: 804
------------------------------------------------------
eims_get_ctl_type_list = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local dataver = xml_opt:get_node_value(get_label_path("data", "data_ver"))
	local sql = "select * from t_control_types where data_version > '"..eims_safety(dataver).."' order by `order`"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local rowcount = mysql_opt:get_row_count()
	local dl = get_label_path("data")
	local ctltype = get_label_path("ctl_type")
	local ctltypes = ctltype.."s"
	xml_opt:add_child_node(ctltypes, "", dl)
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(ctltype..tostring(i), "", dl.."/"..ctltypes)
		local p = dl.."/"..ctltypes.."/"..ctltype..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("parent_id"), mysql_opt:get_query_result(i, "parent_id"), p)
		xml_opt:add_child_node( get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
		xml_opt:add_child_node( get_label_path("code"), mysql_opt:get_query_result(i, "code"), p)
		xml_opt:add_child_node( get_label_path("description"), mysql_opt:get_query_result(i, "description"), p)
		xml_opt:add_child_node( get_label_path("order"), mysql_opt:get_query_result(i, "order"), p)
		xml_opt:add_child_node( get_label_path("is_use"), mysql_opt:get_query_byte_result(i, "is_use"), p)
		xml_opt:add_child_node( get_label_path("data_ver"), mysql_opt:get_query_result(i, "data_version"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


---------------------------------------------
--
--	old: 0x44    获取功能控件列表
--	new: 805
---------------------------------------------
eims_get_fun_ctl_list = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local dataver = xml_opt:get_node_value(get_label_path("data", "data_ver"))
	local sql = "select * from t_controls where data_version > '"..eims_safety(dataver).."' order by `id`"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local rowcount = mysql_opt:get_row_count()
	local dl = get_label_path("data")
	local functl = get_label_path("fun_ctl")
	local functls = functl.."s"
	xml_opt:add_child_node(functls, "", dl)
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(functl..tostring(i), "", dl.."/"..functls)
		local p = dl.."/"..functls.."/"..functl..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("guid"), mysql_opt:get_query_result(i, "guid"), p)
		xml_opt:add_child_node( get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
		xml_opt:add_child_node( get_label_path("description"), mysql_opt:get_query_result(i, "description"), p)
		xml_opt:add_child_node( get_label_path("keyword"), mysql_opt:get_query_result(i, "keyword"), p)
		xml_opt:add_child_node( get_label_path("control_type_id"), mysql_opt:get_query_result(i, "control_type_id"), p)
		xml_opt:add_child_node( get_label_path("creater_user_id"), mysql_opt:get_query_result(i, "creater_user_id"), p)
		xml_opt:add_child_node( get_label_path("create_time"), mysql_opt:get_query_result(i, "create_time"), p)
		xml_opt:add_child_node( get_label_path("is_free"), mysql_opt:get_query_byte_result(i, "is_free"), p)
		xml_opt:add_child_node( get_label_path("ftp_ip"), mysql_opt:get_query_result(i, "ftp_ip"), p)
		xml_opt:add_child_node( get_label_path("ftp_port"), mysql_opt:get_query_result(i, "ftp_port"), p)
		xml_opt:add_child_node( get_label_path("ftp_username"), mysql_opt:get_query_result(i, "ftp_username"), p)
		xml_opt:add_child_node( get_label_path("ftp_password"), mysql_opt:get_query_result(i, "ftp_password"), p)
		xml_opt:add_child_node( get_label_path("ftp_path"), mysql_opt:get_query_result(i, "ftp_path"), p)
		xml_opt:add_child_node( get_label_path("frequency_of_use"), mysql_opt:get_query_result(i, "frequency_of_use"), p)
		xml_opt:add_child_node( get_label_path("help"), mysql_opt:get_query_result(i, "help"), p)
		xml_opt:add_child_node( get_label_path("sample_url"), mysql_opt:get_query_result(i, "sample_url"), p)
		xml_opt:add_child_node( get_label_path("version"), mysql_opt:get_query_result(i, "version"), p)
		xml_opt:add_child_node( get_label_path("data_ver"), mysql_opt:get_query_result(i, "data_version"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x01    获取服务器类型、版本
--	new: 812
---------------------------------------------
eims_get_server_ver_and_type = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	xml_opt:add_child_node( get_label_path("svr_info"), "Welcome to eims_server_terminal. Version: 2.0.0", get_label_path("data"))
	xml_opt:add_child_node( get_label_path("err_desc"), tostring(tool:get_data_seq()), get_label_path("data"))

	return xml_opt:create_xml_string()
end


---------------------------------------------
--
--	old: 0x15  心跳包(客户端状态,登录次数,eimsID,identityID,......,信息内容,错误返回)
--	new: 801
---------------------------------------------
eims_heart_beat_packet = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local defaultident = xml_opt:get_node_value(get_label_path("data", "default_identity"))
	local sitever = xml_opt:get_node_value(get_label_path("data", "site_ver"))

	-- get user information
	local sql = "select user_state,login_count,default_identity from t_users where id = "..eims_safety(userid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "用户不存在")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local p = get_label_path("data")
	xml_opt:add_child_node(get_label_path("user_state"), mysql_opt:get_query_result(0, "user_state"), p)
	xml_opt:add_child_node(get_label_path("login_count"), mysql_opt:get_query_result(0, "login_count"), p)
	--xml_opt:add_child_node(get_label_path("default_identity"), mysql_opt:get_query_result(0, "default_identity"), p)
	mysql_opt:release_res()

	--get notify
	sql = "select id from t_notify"
	if defaultident == "1" then
		sql = sql.." where on_time < now()"
		sql = sql.." and ((to_soft_owner = 1 or to_soft_user = 1) or `id` in (select notify_id from t_notify_custom "
		sql = sql.." where user_id = "..eims_safety(userid)..")) and not `id` in (select notify_id from t_notify_accepted where user_id = "..eims_safety(userid)..") order by `id`"
	else 
		if defaultident == "2" then
			sql = sql.." where on_time < now()"
			sql = sql.." and ((to_soft_user = 1) or `id` in (select notify_id from t_notify_custom where user_id = "..eims_safety(userid)..")) "
			sql = sql.." and not `id` in (select notify_id from t_notify_accepted where user_id = "..eims_safety(userid)..") order by `id`"
		else 
			if defaultident == "3" then
				sql = sql.." where on_time < now()"
				sql = sql.." and ((to_site_owner = 1 or to_site_user = 1) or `id` in (select notify_id from t_notify_custom "
				sql = sql.." where user_id = "..eims_safety(userid)..")) and not `id` in (select notify_id from t_notify_accepted where user_id = "..eims_safety(userid)..") order by `id`"
			else 
				if defaultident == "4" then
					sql = sql.." where on_time < now()"
					sql = sql.." and ((to_site_user = 1) or `id` in (select notify_id from t_notify_custom where user_id = "..eims_safety(userid)..")) "
					sql = sql.." and not `id` in (select notify_id from t_notify_accepted where user_id = "..eims_safety(userid)..") order by `id`"
				else
					logger:WriteLog("label identity is not valid", EIMS_LOG_LEVEL.ERROR)
					return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "消息错误，服务器拒绝响应")
				end
			end
		end
	end
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		xml_opt:add_child_node(get_label_path("have_new_notify"), "0", p)
	else
		xml_opt:add_child_node(get_label_path("have_new_notify"), "1", p)
	end

	-- get user message
	sql = "select id from t_messages where locate("..eims_safety(userid)..",receive_id) > 0"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		xml_opt:add_child_node(get_label_path("have_msg"), "0", p)
	else
		xml_opt:add_child_node(get_label_path("have_msg"), "1", p)
	end
	mysql_opt:release_res()

	-- get all sites
	sql = "select id from t_sites where (creater_id = "..eims_safety(userid).." or owner_id = "..eims_safety(userid).." ) and data_version > '"..eims_safety(sitever).."' order by `id`"
	if mysql_opt:oper_db(sql) ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		xml_opt:add_child_node(get_label_path("have_new_site"), "0", p)
	else
		xml_opt:add_child_node(get_label_path("have_new_site"), "1", p)
	end
	mysql_opt:release_res()

	-- get site using
	sql = "select a.id from t_sites as a, (select site_id from t_site_user_id_list where ((user_id = "..eims_safety(userid).." and group_id = -1) or "
	sql = sql.."group_id = -3 or group_id in (select group_id from t_user_in_sitegroup where user_id = "..eims_safety(userid)..")) and "
	sql = sql.."t_site_user_id_list.data_version > '"..eims_safety(sitever).."') as b where a.is_deleted = 0 and a.`id` = b.site_id"
	if mysql_opt:oper_db(sql) ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		xml_opt:add_child_node(get_label_path("have_new_use_site"), "0", p)
	else
		xml_opt:add_child_node(get_label_path("have_new_use_site"), "1", p)
	end

	-- get latest info
	sql = "select ctls_latest_ver,ctl_type_latest_ver,app_int_latest_ver,app_latest_ver,app_type_latest_ver,trade_types_latest_ver,"
	sql = sql.."provinces_latest_ver,citys_latest_ver,areas_latest_ver,notify_types_latest_ver,mode_latest_ver,fun_ctl_latest_ver,"
	sql = sql.."user_ctl_latest_ver from t_latest_things";
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "没有找到版本信息")
	end
	
	xml_opt:add_child_node(get_label_path("ctls_ver"), mysql_opt:get_query_result(0, "ctls_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("ctl_type_ver"), mysql_opt:get_query_result(0, "ctl_type_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("app_int_ver"), mysql_opt:get_query_result(0, "app_int_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("app_ver"), mysql_opt:get_query_result(0, "app_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("app_type_ver"), mysql_opt:get_query_result(0, "app_type_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("trade_types_ver"), mysql_opt:get_query_result(0, "trade_types_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("provinces_ver"), mysql_opt:get_query_result(0, "provinces_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("notify_types_ver"), mysql_opt:get_query_result(0, "notify_types_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("areas_ver"), mysql_opt:get_query_result(0, "areas_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("mode_ver"), mysql_opt:get_query_result(0, "mode_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("fun_ctl_ver"), mysql_opt:get_query_result(0, "fun_ctl_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("user_ctl_ver"), mysql_opt:get_query_result(0, "user_ctl_latest_ver"), p)
	xml_opt:add_child_node(get_label_path("citys_ver"), mysql_opt:get_query_result(0, "citys_latest_ver"), p)
	mysql_opt:release_res()

	return xml_opt:create_xml_string()

end

---------------------------------------------
--
--	old: 0x45    获取省份列表
--	new: 806
---------------------------------------------
eims_get_province_list = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local dataver = xml_opt:get_node_value(get_label_path("data", "data_ver"))

	local sql = "select id, name, data_version from t_provinces where data_version > '"..eims_safety(dataver).."' order by `id`"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local rowcount = mysql_opt:get_row_count()
	local dl = get_label_path("data")
	local province = get_label_path("province")
	local provinces = province.."s"
	xml_opt:add_child_node(provinces, "", dl)
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(province..tostring(i), "", dl.."/"..provinces)
		local p = dl.."/"..provinces.."/"..province..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
		xml_opt:add_child_node( get_label_path("data_ver"), mysql_opt:get_query_result(i, "data_version"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x46    获取城市列表
--	new: 807
---------------------------------------------
eims_get_city_list = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local dataver = xml_opt:get_node_value(get_label_path("data", "data_ver"))
	local sql = "select id,name,province_id,data_version from t_citys where `data_version` > '"..eims_safety(dataver).."' order by `id`"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local rowcount = mysql_opt:get_row_count()
	local dl = get_label_path("data")
	local city = get_label_path("city")
	local citys = city.."s"
	xml_opt:add_child_node(citys, "", dl)
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(city..tostring(i), "", dl.."/"..citys)
		local p = dl.."/"..citys.."/"..city..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
		xml_opt:add_child_node( get_label_path("province_id"), mysql_opt:get_query_result(i, "province_id"), p)
		xml_opt:add_child_node( get_label_path("data_ver"), mysql_opt:get_query_result(i, "data_version"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end

---------------------------------------------
--
--	old: 0x47    获取区县列表
--	new: 808
---------------------------------------------
eims_get_area_list = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local dataver = xml_opt:get_node_value(get_label_path("data", "data_ver"))

	local sql = "select id,name,city_id,data_version from t_areas where `data_version` > '"..eims_safety(dataver).."' order by `id`"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error,instruction is "..instruction..",sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local rowcount = mysql_opt:get_row_count()
	local dl = get_label_path("data")
	local area = get_label_path("area")
	local areas = area.."s"
	xml_opt:add_child_node(areas, "", dl)
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(area..tostring(i), "", dl.."/"..areas)
		local p = dl.."/"..areas.."/"..area..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
		xml_opt:add_child_node( get_label_path("city_id"), mysql_opt:get_query_result(i, "city_id"), p)
		xml_opt:add_child_node( get_label_path("data_ver"), mysql_opt:get_query_result(i, "data_version"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


-----no done
eims_get_model_ctl_usercount = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
end

