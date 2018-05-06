--------------------------------------------------------------------
--
--	notify and message manager 
--
--------------------------------------------------------------------

package.path = package.path ..";./?.lua;../other/script/?.lua;./script/?.lua"
require("eims_log")
require("eims_common")
require("eims_error")
require("eims_message")

--------------------------------------------------------------------
--
--	old: 0x41    根据当前登录用户, 获取应该收到的弹窗通知列表
--	new: 501
--------------------------------------------------------------------
eims_get_user_notifies = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local default_ident = xml_opt:get_node_value(get_label_path("data", "default_identity"))
	local sql = "select id,title,content,url,show_second,sender_id,type_id,reader_count,is_show_window from t_notify"
	if default_ident == "1" then
		sql = sql.." where on_time < now()"
		sql = sql.." and ((to_soft_owner = 1 or to_soft_user = 1) or `id` in (select notify_id from t_notify_custom "
		sql = sql.." where user_id = "..eims_safety(userid)..")) and not `id` in (select notify_id from t_notify_accepted where user_id = "..eims_safety(userid)..") order by `id`"
	else 
		if default_ident == "2" then
			sql = sql.." where on_time < now()"
			sql = sql.." and ((to_soft_user = 1) or `id` in (select notify_id from t_notify_custom where user_id = "..eims_safety(userid)..")) "
			sql = sql.." and not `id` in (select notify_id from t_notify_accepted where user_id = "..eims_safety(userid)..") order by `id`"
		else 
			if default_ident == "3" then
				sql = sql.." where on_time < now()"
				sql = sql.." and ((to_site_owner = 1 or to_site_user = 1) or `id` in (select notify_id from t_notify_custom "
				sql = sql.." where user_id = "..eims_safety(userid)..")) and not `id` in (select notify_id from t_notify_accepted where user_id = "..eims_safety(userid)..") order by `id`"
			else 
				if default_ident == "4" then
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

	local rowcount = mysql_opt:get_row_count()
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local dl = get_label_path("data")
	local nl = get_label_path("notify")
	local nls = nl.."s"
	xml_opt:add_child_node(nls, "", dl)
	local cond = ""
	for i = 0, rowcount - 1 do
		if i > 0 then
			cond = ","..cond
		end
		--cond = cond..get_label_path("id")
		cond = mysql_opt:get_query_result(i, "id")..cond
		xml_opt:add_child_node(nl..tostring(i), "", dl.."/"..nls)
		local p = dl.."/"..nls.."/"..nl..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("title"), mysql_opt:get_query_result(i, "title"), p)
		xml_opt:add_child_node( get_label_path("content"), mysql_opt:get_query_result(i, "content"), p)
		xml_opt:add_child_node( get_label_path("url"), mysql_opt:get_query_result(i, "url"), p)
		xml_opt:add_child_node( get_label_path("show_second"), mysql_opt:get_query_result(i, "show_second"), p)
		xml_opt:add_child_node( get_label_path("sender_id"), mysql_opt:get_query_result(i, "sender_id"), p)
		xml_opt:add_child_node( get_label_path("type_id"), mysql_opt:get_query_result(i, "type_id"), p)
		xml_opt:add_child_node( get_label_path("reader_count"), mysql_opt:get_query_result(i, "reader_count"), p)
		xml_opt:add_child_node( get_label_path("is_show_window"), mysql_opt:get_query_result(i, "is_show_window"), p)
	end
	mysql_opt:release_res()

	if cond ~= "" then
		sql = "insert into t_notify_accepted (user_id, notify_id) select "..eims_safety(userid).." as user_id, `id` from t_notify where `id` in ("..eims_safety(cond)..")"
		result = mysql_opt:oper_db_trans_exc_v2(sql, true)
		if result ~= 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
	end
	return xml_opt:create_xml_string()
end


--------------------------------------------------------------------
--
--	old: 0x23     接收用户发送的信息
--	new: 502
--------------------------------------------------------------------
eims_send_chat_message = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local recvid = xml_opt:get_node_value(get_label_path("data", "receive_id"))
	local content = xml_opt:get_node_value(get_label_path("data", "content"))
	local sql = "insert into t_messages (sender_id, receive_id, receive_id_list, content, sender_time) values ("..eims_safety(userid)..", '"..eims_safety(recvid).."', '"..eims_safety(recvid).."', '"..eims_safety(content).."', now())"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end


--------------------------------------------------------------------
--
--	old: 0x24     发送用户需要的信息 根据 user_id 获取当前用户在聊天表中需要接收的数据
--	new: 503
--------------------------------------------------------------------
eims_get_chat_message = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local sql = "select id, sender_id, sender_time, content from t_messages where locate('"..eims_safety(userid).."', receive_id) > 0"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local msg = get_label_path("user_msg")
	local msgs = msg.."s"
	xml_opt:add_child_node(msgs, "", data)
	local rowcount = mysql_opt:get_row_count()
	local msgid = ""
	for i = 0, rowcount - 1 do
		if i > 0 then
			msgid = ","..msgid
		end
		msgid = mysql_opt:get_query_result(i, "id")..msgid
		xml_opt:add_child_node(msg..tostring(i), "", data.."/"..msgs)
		local p = data.."/"..msgs.."/"..msg..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("sender_id"), mysql_opt:get_query_result(i, "sender_id"), p)
		xml_opt:add_child_node( get_label_path("sender_time"), mysql_opt:get_query_result(i, "sender_time"), p)
		xml_opt:add_child_node( get_label_path("content"), mysql_opt:get_query_result(i, "content"), p)
	end
	mysql_opt:release_res()

	if msgid ~= "" then
		local ids = userid
		sql = "update t_messages set receive_id = replace(receive_id, '"..ids.."', ',') where id in ("..msgid..")"
		--print(sql)
		result = mysql_opt:oper_db(sql)
		if result ~= 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
	end
	return xml_opt:create_xml_string()
end


--------------------------------------------------------------------
--
--	old: 心跳包函数   根据当前登录用户, 获取应该收到的【应用】弹窗通知列表
--	new: 504
--------------------------------------------------------------------
eims_get_user_app_notifys = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))

	local sql = "SELECT * FROM t_application_notify WHERE `on_time` < now() AND (("
		  sql = sql.."`to_app_owner` = 1 AND application_id IN (SELECT `application_id` FROM t_sites WHERE `application_id` in (select id from t_applications where id > 2)AND is_deleted = 0 AND `creater_id` = "..eims_safety(userid)..")"
		  sql = sql..") OR ( `to_app_user` = 1 AND `application_id` IN "
		  sql = sql.."(SELECT `application_id` FROM t_sites WHERE `application_id` in (select id from t_applications where id > 3)AND `Id` IN (SELECT`site_id`FROM t_site_user_id_list WHERE`user_id` = "..eims_safety(userid).."))"
		  sql = sql..") OR `id` IN (SELECT`notify_id`FROM t_application_notify_custom WHERE `user_id` = "..eims_safety(userid).."))"
		  sql = sql.."AND NOT `id` IN (SELECT `notify_id` FROM t_application_notify_accepted WHERE `user_id` = "..eims_safety(userid).." ) ORDER BY `id`"

	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local msg = get_label_path("app_notify")
	local msgs = msg.."s"
	xml_opt:add_child_node(msgs, "", data)
	local rowcount = mysql_opt:get_row_count()
	local accept_notifys = ""
	for i = 0, rowcount - 1 do
		if i > 0 then
			accept_notifys = ","..accept_notifys
		end
		accept_notifys = mysql_opt:get_query_result(i, "id")..accept_notifys
		xml_opt:add_child_node(msg..tostring(i), "", data.."/"..msgs)
		local p = data.."/"..msgs.."/"..msg..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("title"), mysql_opt:get_query_result(i, "title"), p)
		xml_opt:add_child_node( get_label_path("content"), mysql_opt:get_query_result(i, "content"), p)
		xml_opt:add_child_node( get_label_path("url"), mysql_opt:get_query_result(i, "url"), p)
		xml_opt:add_child_node( get_label_path("show_second"), mysql_opt:get_query_result(i, "show_second"), p)
		xml_opt:add_child_node( get_label_path("sender_id"), mysql_opt:get_query_result(i, "sender_id"), p)
		xml_opt:add_child_node( get_label_path("app_id"), mysql_opt:get_query_result(i, "application_id"), p)
		xml_opt:add_child_node( get_label_path("type_id"), mysql_opt:get_query_result(i, "type_id"), p)
		xml_opt:add_child_node( get_label_path("reader_count"), mysql_opt:get_query_result(i, "reader_count"), p)
		xml_opt:add_child_node( get_label_path("is_show_window"), mysql_opt:get_query_result(i, "is_show_window"), p)
	end
	mysql_opt:release_res()

	if accept_notifys ~= "" then
		sql = "insert into t_application_notify_accepted (user_id, notify_id) select "..eims_safety(userid).." as user_id, `id` from t_application_notify "
		sql = sql.."where `id` in ("..accept_notifys..")"
		result = mysql_opt:oper_db(sql)
		if result ~= 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
	end
	return xml_opt:create_xml_string()
end


--------------------------------------------------------------------
--
--	old: 0x75    获取应用消息阅读次数
--	new: 505
--------------------------------------------------------------------
eims_get_user_app_notifys_readcount = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local notifyid = xml_opt:get_node_value(get_label_path("data", "notify_id"))
	local sql = "select `reader_count` from t_application_notify where `Id` = "..eims_safety(notifyid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	
	if mysql_opt:get_row_count() > 0 then
		xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
		local readcount = mysql_opt:get_query_result(0, "reader_count")
		mysql_opt:release_res()

		sql = "update t_application_notify set `reader_count` = IFNULL(`reader_count`,0) + 1 where `Id` = "..eims_safety(notifyid)
		result = mysql_opt:oper_db(sql)
		if result ~= 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
		xml_opt:add_child_node(get_label_path("notify_id"), notifyid, get_label_path("data"))
		xml_opt:add_child_node(get_label_path("read_count"), tostring(readcount), get_label_path("data"))
		return xml_opt:create_xml_string()
	end
	return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "找不到该通知")
end


--------------------------------------------------------------------
--
--	old: 0x74    获取系统消息阅读次数
--	new: 506
--------------------------------------------------------------------
eims_get_system_notifys_readcount = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local notifyid = xml_opt:get_node_value(get_label_path("data", "notify_id"))
	local sql = "select `reader_count` from t_notify where `Id` = "..eims_safety(notifyid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local rowcount = mysql_opt:get_row_count()
	if rowcount > 0 then
		local readcount = mysql_opt:get_query_result(0, "reader_count")
		mysql_opt:release_res()

		sql = "update t_notify set `reader_count` = IFNULL(`reader_count`,0) + 1 where `Id` = "..eims_safety(notifyid)
		result = mysql_opt:oper_db(sql)
		if result ~= 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
		xml_opt:add_child_node(get_label_path("notify_id"), notifyid, get_label_path("data"))
		xml_opt:add_child_node(get_label_path("read_count"), tostring(readcount), get_label_path("data"))
		return xml_opt:create_xml_string()
	end
	return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "该通知不存在")
end


--------------------------------------------------------------------
--
--	old: 0x73    获取消息类别表
--	new: 507
--------------------------------------------------------------------
eims_get_notify_type = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local dataver = xml_opt:get_node_value(get_label_path("data", "data_ver"))
	local sql = "select * from t_notify_type where data_version > '"..eims_safety(dataver).."' order by `order`"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	local type = get_label_path("notify_type")
	local types = type.."s"
	xml_opt:add_child_node(types, "", data)
	local rowcount = mysql_opt:get_row_count()
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(type..tostring(i), "", data.."/"..types)
		local p = data.."/"..types.."/"..type..tostring(i)
		xml_opt:add_child_node( get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
		xml_opt:add_child_node( get_label_path("parent_id"), mysql_opt:get_query_result(i, "parent_id"), p)
		xml_opt:add_child_node( get_label_path("name"), mysql_opt:get_query_result(i, "name"), p)
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
--	old: part of login function
--	new: 520
---------------------------------------------
eims_get_all_notify_type = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local sql = "select `id` from t_notify_type"

	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local rowcount = mysql_opt:get_row_count()
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local dl = get_label_path("data")
	local nt = get_label_path("notify_type")
	local nts = nt.."s"
	xml_opt:add_child_node(nts, "", dl)
	for i = 0, rowcount - 1 do
		local p = dl.."/"..nts.."/"..nt..tostring(i)
		xml_opt:add_child_node(nt..tostring(i), "", dl.."/"..nts)
		xml_opt:add_child_node(get_label_path("id"), mysql_opt:get_query_result(i, "id"), p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end
