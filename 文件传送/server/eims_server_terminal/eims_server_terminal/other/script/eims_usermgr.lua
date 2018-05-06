package.path = package.path ..";./?.lua;../other/script/?.lua;./script/?.lua"

require("eims_log")
require("eims_error")
require("eims_common")
require("eims_message")


-------------------------------------------------------
---
---	get user infomation function
---
-------------------------------------------------------
eims_get_usr_info = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))

	local sql = "select id,name,reality_name,last_login_time,last_login_ip,register_time,default_identity,soft_type,soft_owner_id,"
	sql = sql.."site_owner_id,company_name,login_count,sex,is_actived,fax_number,creater_id,balance,email,email_verified,home_address,"
	sql = sql.."telephone,office_telephone,mobile,mobile_verified,id_card_number,address,postcode,ukey from t_users where id = "..eims_safety(userid)
	--local sql = "call func_get_user_info("..userid..")"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local count = mysql_opt:get_row_count()
	if tonumber(count) <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	xml_opt:add_child_node(get_label_path("user_id"), 			mysql_opt:get_query_result(0, "id"), 				data)
	xml_opt:add_child_node(get_label_path("name"), 				mysql_opt:get_query_result(0, "name"), 				data)
	xml_opt:add_child_node(get_label_path("reality_name"), 		mysql_opt:get_query_result(0, "reality_name"),  	data)
	xml_opt:add_child_node(get_label_path("last_login_time"), 	mysql_opt:get_query_result(0, "last_login_time"), 	data)
	xml_opt:add_child_node(get_label_path("last_login_ip"), 	mysql_opt:get_query_result(0, "last_login_ip"), 	data)
	xml_opt:add_child_node(get_label_path("reg_time"), 			mysql_opt:get_query_result(0, "register_time"), 	data)
	xml_opt:add_child_node(get_label_path("company_name"), 		mysql_opt:get_query_result(0, "company_name"), 		data)
	xml_opt:add_child_node(get_label_path("login_count"), 		mysql_opt:get_query_result(0, "login_count"), 		data)
	xml_opt:add_child_node(get_label_path("gender"), 			mysql_opt:get_query_byte_result(0, "sex"), 			data)
	xml_opt:add_child_node(get_label_path("is_actived"), 		mysql_opt:get_query_byte_result(0, "is_actived"), 	data)
	xml_opt:add_child_node(get_label_path("default_identity"), 	mysql_opt:get_query_result(0, "default_identity"), 	data)
	xml_opt:add_child_node(get_label_path("postcode"), 			mysql_opt:get_query_result(0, "postcode"), 			data)
	xml_opt:add_child_node(get_label_path("email"), 			mysql_opt:get_query_result(0, "email"), 			data)
	xml_opt:add_child_node(get_label_path("email_verified"), 	mysql_opt:get_query_byte_result(0, "email_verified"), data)
	xml_opt:add_child_node(get_label_path("home_addr"), 		mysql_opt:get_query_result(0, "home_address"), 		data)
	xml_opt:add_child_node(get_label_path("mobile"), 			mysql_opt:get_query_result(0, "mobile"), 			data)
	xml_opt:add_child_node(get_label_path("mobile_verified"), 	mysql_opt:get_query_byte_result(0, "mobile_verified"), data)
	xml_opt:add_child_node(get_label_path("fax"), 				mysql_opt:get_query_result(0, "fax_number"), 		data)
	xml_opt:add_child_node(get_label_path("soft_owner_id"), 	mysql_opt:get_query_result(0, "soft_owner_id"), 	data)
	xml_opt:add_child_node(get_label_path("creater_id"), 		mysql_opt:get_query_result(0, "creater_id"), 		data)
	xml_opt:add_child_node(get_label_path("balance"), 			mysql_opt:get_query_result(0, "balance"), 			data)
	xml_opt:add_child_node(get_label_path("ukey"), 				mysql_opt:get_query_result(0, "ukey"), 				data)
	xml_opt:add_child_node(get_label_path("address"), 			mysql_opt:get_query_result(0, "address"), 			data)
	xml_opt:add_child_node(get_label_path("id_card_num"), 		mysql_opt:get_query_result(0, "id_card_number"), 	data)
	xml_opt:add_child_node(get_label_path("soft_type"), 		mysql_opt:get_query_result(0, "soft_type"), 		data)
	xml_opt:add_child_node(get_label_path("tel"), 				mysql_opt:get_query_result(0, "telephone"), 		data)
	xml_opt:add_child_node(get_label_path("office_tel"), 		mysql_opt:get_query_result(0, "office_telephone"), 	data)
	mysql_opt:release_res()

	return xml_opt:create_xml_string()
end


-------------------------------------------------------
---
---	set user infomation function
---
-------------------------------------------------------
eims_update_user_info = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )

	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local name = xml_opt:get_node_value(get_label_path("data", "name"))
	local gender = xml_opt:get_node_value(get_label_path("data", "gender"))
	local email = xml_opt:get_node_value(get_label_path("data", "email"))
	local mobile = xml_opt:get_node_value(get_label_path("data", "mobile"))
	local officetel = xml_opt:get_node_value(get_label_path("data", "office_tel"))
	local homeaddress = xml_opt:get_node_value(get_label_path("data", "home_addr"))
	local fax = xml_opt:get_node_value(get_label_path("data", "fax"))
	local postcode = xml_opt:get_node_value(get_label_path("data", "postcode"))
	local companyname = xml_opt:get_node_value(get_label_path("data", "company_name"))

	local sql = "select id, email, email_verified, mobile, mobile_verified from t_users where `id` =  "..eims_safety(userid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end

	local e_ver = mysql_opt:get_query_byte_result(0, "email_verified")
	local m_ver = mysql_opt:get_query_byte_result(0, "mobile_verified")
	local o_email = mysql_opt:get_query_result(0, "email")
	local o_mobile = mysql_opt:get_query_result(0, "mobile")
	if o_email ~= email then
		e_ver = "0"
	end
	if o_mobile ~= mobile then
		m_ver = "0"
	end
	mysql_opt:release_res()

	local sql = "update t_users set name = '"..eims_safety(name).."', sex = "..gender..", email = '"..email.."', email_verified = "..e_ver..", "
	sql = sql.."mobile = '"..eims_safety(mobile).."', mobile_verified = "..m_ver..", office_telephone = '"..eims_safety(officetel).."'," 
	sql = sql.."home_address = '"..eims_safety(homeaddress).."', fax_number = '"..eims_safety(fax).."', postcode = '"..eims_safety(postcode).."', "
	sql = sql.."company_name = '"..eims_safety(companyname).."' where `id` = "..eims_safety(userid)

	--print(sql)

	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	xml_opt:add_child_node(get_label_path("user_id"), userid, get_label_path("data"))

	return xml_opt:create_xml_string()

end

-------------------------------------------------------
---
---	get user state function
---
-------------------------------------------------------
eims_get_user_state = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )

	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))

	local sql = "select user_state, login_count from t_users where `id` = "..eims_safety(userid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local count = mysql_opt:get_row_count()
	if tonumber(count) <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end

	--xml_opt:load_xml_data(message_base_response_style, "message")
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local data = get_label_path("data")
	xml_opt:add_child_node(get_label_path("user_id"), 		userid, 										data)
	xml_opt:add_child_node(get_label_path("user_state"), 	mysql_opt:get_query_result(0, "user_state"), 	data)
	xml_opt:add_child_node(get_label_path("login_count"), 	mysql_opt:get_query_result(0, "login_count"), 	data)
	mysql_opt:release_res()

	return xml_opt:create_xml_string()

end


-------------------------------------------------------
---
---	set user state function
---
-------------------------------------------------------
eims_set_user_state = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local state = xml_opt:get_node_value(get_label_path("data", "state"))

	local sql = "update t_users set user_state = "..eims_safety(state).." where id = "..eims_safety(userid)

	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	xml_opt:add_child_node(get_label_path("user_id"), userid, get_label_path("data"))
	xml_opt:add_child_node(get_label_path("user_state"), state, get_label_path("data"))

	return xml_opt:create_xml_string()
end

-------------------------------------------------------
---
---	set user password function
---
-------------------------------------------------------
eims_change_password = function(xml_opt, mysql_opt)
	--body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local oldpwd = xml_opt:get_node_value(get_label_path("data", "old_pwd"))
	local newpwd = xml_opt:get_node_value(get_label_path("data", "new_pwd"))


	local sql = "select id from t_users where id = "..eims_safety(userid).." and password ='"..tool:handlePassword(oldpwd).."'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local count = mysql_opt:get_row_count()
	if count == 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户名或密码错误")
	end
	mysql_opt:release_res()

	sql = "update t_users set password = '"..tool:handlePassword(newpwd).."' where id = "..eims_safety(userid).." and password = '"..tool:handlePassword(oldpwd).."'"
	print(sql)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	xml_opt:add_child_node(get_label_path("user_id"), userid, get_label_path("data"))

	return xml_opt:create_xml_string()

end

---------------------------------------------------
--
--	reset password
--
---------------------------------------------------
eims_reset_password = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local mobile = xml_opt:get_node_value(get_label_path("data", "mobile"))

	local sql = "select name, email, email_verified from t_users where `id` = "..eims_safety(userid).." or `mobile` = '"..eims_safety(mobile).."'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local row_num = mysql_opt:get_row_count()
	if row_num <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end

	local e_verify = mysql_opt:get_query_byte_result(0, "email_verified")
	if e_verify ~= "1" then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "邮箱尚未验证，无法重置密码")
	end
	local email = mysql_opt:get_query_result(0, "email")
	local new_pwd = tool:get_rand_num(6)
	local name = mysql_opt:get_query_result(0, "name")
	mysql_opt:release_res()
	
	local subject = "尊敬的犀牛云用户，您好！您在犀牛云的用户登录密码已找回，请查收！"
    local body = "尊敬的犀牛云 ["
    body = body..name
    body = body.."]用户，您好：<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;您在犀牛云的登录密码已经重置为 "
    body = body..new_pwd
    body = body.."，为了您账户的安全，请及时登录平台进行修改！谢谢。"

    sql = "update t_users set `password` = '"..tool:handlePassword(new_pwd).."' where `id` = "..eims_safety(userid).." or mobile = '"..eims_safety(mobile).."'"
    result = mysql_opt:oper_db_trans_exc_v2(sql, false)
    if result < 0 then
    	logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
    	return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
    end


    sql = "insert into t_send_emails (email, `subject`, body) values ('"..eims_safety(email).."', '"..eims_safety(subject).."', '"..eims_safety(body).."')"

    result = mysql_opt:oper_db_trans_exc_v2(sql, true)
    if result < 0 then
    	logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
    	return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
    end

    xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	xml_opt:add_child_node(get_label_path("user_id"), userid, get_label_path("data"))

	return xml_opt:create_xml_string()

end


eims_get_userid_by_email = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local email = xml_opt:get_node_value(get_label_path("data", "email"))

	local sql = "select id, name, reality_name, email_verified, default_identity, is_actived from t_users where email = '"..eims_safety(email).."'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "邮箱不存在")
	end

	local is_verify = mysql_opt:get_query_byte_result(0, "email_verified")
	if is_verify ~= "1" then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "邮箱尚未验证，无法获取用户信息")
	end

	local userid = mysql_opt:get_query_result(0, "id")
	local name = mysql_opt:get_query_result(0, "name")
	local realityname = mysql_opt:get_query_result(0, "reality_name")
	local default_identity = mysql_opt:get_query_result(0, "default_identity")
	local user_is_actived = mysql_opt:get_query_byte_result(0, "is_actived")
	mysql_opt:release_res()

	local subject = "尊敬的犀牛云用户，您好！您在犀牛云的犀牛账号已找回，请查收！";
    local body = "尊敬的犀牛云 [";
    body = body..name;
    body = body.."]用户，您好：<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;您在犀牛云的犀牛账号信息是：<br /><br />";
    body = body.."犀牛账号: ";
    body = body..userid;
    body = body.."<br />用户名: ";
    body = body..name;
    body = body.."<br />真实姓名: ";
    body = body..realityname;
    body = body.."<br />犀牛云客户端激活: ";
    if user_is_actived == "0" then
    	body = body.."未激活"
    else
    	body = body.."已激活"
    end
    body = body.."<br />犀牛云客户端身份: ";
    local ident = ""
    if default_identity == 1 then
    	ident = "软件注册者"
    else 
    	if default_identity == 2 then
    	ident = "软件使用者"
    	else 
    		if default_identity == 3 then
    		ident = "网站所有者"
    		else 
    			if default_identity == 4 then
    			ident = "网站使用者"
    			else 
    			ident = "未知"
    			end
    		end
    	end
    end

    body = body..ident
    body = body.."<br /><br />为了您账户的安全，请及时登录平台修改相关信息以及登录密码！谢谢。";

    sql = "insert into t_send_emails (email, subject, body) values ('"..eims_safety(email).."', '"..eims_safety(subject).."','"..eims_safety(body).."')"
    result = mysql_opt:oper_db(sql)
    if result ~= 0 then
    	logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
    	return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
    end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end


--------------------------------------------------------------------
--
--	parent change child password func
--
--------------------------------------------------------------------
eims_parent_change_child_password = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local parentid = xml_opt:get_node_value(get_label_path("data", "parent_id"))
	local parentpwd = xml_opt:get_node_value(get_label_path("data", "parent_pwd"))
	local childid = xml_opt:get_node_value(get_label_path("data", "child_id"))
	local childpwd = xml_opt:get_node_value(get_label_path("data", "child_pwd"))

	local sql = "select id, password from t_users where `id` = "..eims_safety(parentid).." or `mobile` = '"..eims_safety(parentid).."'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "上级用户不存在")
	end
	local parent_pwd_db = mysql_opt:get_query_result(0, "password")
	if parent_pwd_db ~= tool:handlePassword(parentpwd) then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "上级用户密码错误")
	end
	mysql_opt:release_res()

	sql = "select soft_owner_id, soft_user_id, site_owner_id from t_users where `id` = "..eims_safety(parentid).." or `mobile` = '"..eims_safety(parentid).."'"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local soft_owner_id = mysql_opt:get_query_result(0, "soft_owner_id")
	local soft_user_id = mysql_opt:get_query_result(0, "soft_user_id")
	local site_owner_id = mysql_opt:get_query_result(0, "site_owner_id")

	if parentid ~= soft_owner_id and parentid ~= soft_user_id and parentid ~= site_owner_id then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "上级用户与下级用户不匹配")
	end
	mysql_opt:release_res()

	sql = "update t_users set `password` = '"..tool:handlePassword(childpwd).."' where `id` = "..eims_safety(childid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")

	return xml_opt:create_xml_string()
	
end

eims_mobile_verify = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local mobile = xml_opt:get_node_value(get_label_path("data", "mobile"))

	local sql = "select `name`,`mobile_verified`,`mobile` from t_users where `id` = "..eims_safety(userid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end

	local is_mobile_verified = mysql_opt:get_query_byte_result(0, "mobile_verified")
	if is_mobile_verified == "1" then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户已经被激活")
	end

	local name = mysql_opt:get_query_result(0, "name")
	local old_mobile = mysql_opt:get_query_result(0, "mobile")
	mysql_opt:release_res()

	sql = "select id from t_users where id <>"..eims_safety(userid).." and mobile = '"..eims_safety(mobile).."'"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local row_num = mysql_opt:get_row_count()
	if row_num > 0 then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "手机号码已经被使用")
	end

	sql = "select mobile from t_send_smss where mobile = '"..eims_safety(mobile).."' and is_send = 1 and (TO_DAYS(now()) - TO_DAYS(send_time)) < 1"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败") 
	end

	row_num = mysql_opt:get_row_count()
	if row_num > 3 then
		mysql_opt:release_res()
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "当日发送信息次数过多")
	end
	mysql_opt:release_res()

	sql = "SELECT mobile, "..config.message_check_span.." - (TO_SECONDS(now()) - TO_SECONDS(send_time)) as rt from t_send_smss where mobile = '"..mobile.."' and TO_SECONDS(now()) - TO_SECONDS(send_time)  < "..config.message_check_span
	--sql = "SELECT mobile from t_send_smss where mobile = '"..mobile.."' and is_send = 1 and TIMESTAMPDIFF(SECOND,send_time,now()) < 60"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() > 0 then
		local ts = mysql_opt:get_query_result(0, "rt")
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "校验过于频繁，请在["..tostring(ts).."]秒后重试。")
	end

	if old_mobile ~= mobile then
		local update_sql_mobile = "update t_users set mobile = '"..eims_safety(mobile).."', mobile_verified = 0 where `id` = "..eims_safety(userid)
		result = mysql_opt:oper_db_trans_exc_v2(update_sql_mobile, false)
		if result < 0 then
			logger:WriteLog("db error, message is :"..instruction..", sql is :"..update_sql_mobile, EIMS_LOG_LEVEL.ERROR)
			return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
		end
	end
	local verify_code = tool:get_rand_num(6)
	local updata_sql_verify = "insert into t_mobile_verifying (user_id, mobile, verify_code, try_time) values ("..eims_safety(userid)..", '"..eims_safety(mobile).."', '"..eims_safety(verify_code).."', now())"

	local body = "【犀牛云】账号验证码为:"..verify_code.."，有效时间30分钟，请登陆平台进行激活。"

    local insert_sql = "insert into t_send_smss (mobile, body, send_time) values ('"..eims_safety(mobile).."', '"..eims_safety(body).."', now())"

	result = mysql_opt:oper_db_trans_exc_v2(updata_sql_verify, false)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..updata_sql_verify, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败") 
	end
	result = mysql_opt:oper_db_trans_exc_v2(insert_sql, true)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..insert_sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败") 
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")

	return xml_opt:create_xml_string()

end

eims_mobile_verify_step_2 = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local verify_code = xml_opt:get_node_value(get_label_path("data", "verified_code"))

	local sql = "select `mobile`,`mobile_verified` from t_users where `id` = "..eims_safety(userid).." or `mobile` = '"..eims_safety(userid).."'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end
	mysql_opt:release_res()

	sql = "select `user_id`, `mobile`,`verify_code` from t_mobile_verifying where (user_id = '"..eims_safety(userid).."' or mobile = '"..eims_safety(userid).."') and verify_code = '"..eims_safety(verify_code).."' order by `id` desc limit 0, 1"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "校验码错误")
	end
	mysql_opt:release_res()

	sql = "update t_users set mobile_verified = 1 where `id` = "..eims_safety(userid).." or mobile = '"..eims_safety(userid).."'"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end


	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end


eims_get_all_users = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local readonley_creater = xml_opt:get_node_value(get_label_path("data", "read_only_create_id"))
	local condition = xml_opt:get_node_value(get_label_path("data", "condition"))
	local page_size = xml_opt:get_node_value(get_label_path("data", "page_size"))
	local page_no = xml_opt:get_node_value(get_label_path("data", "page_no"))

	local sql = "select count(1) as rowcount from t_users where (soft_owner_id = "..eims_safety(userid).." or soft_user_id = "..eims_safety(userid)
	sql = sql.." or site_owner_id = "..eims_safety(userid).." or creater_id = "..eims_safety(userid)..") and `id` <> "..eims_safety(userid)

	if readonley_creater == "1" then
        sql = sql.." and (creater_id = "..eims_safety(userid).." and `id` <> "..eims_safety(userid)..")"
    end

    if condition ~= "0" then
        sql = sql.." and ("..eims_safety(condition)..")"
    end
    local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local row_count = mysql_opt:get_row_count()
	if row_count <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")

	local usercount = tonumber(mysql_opt:get_query_result(0, "rowcount"))
	xml_opt:add_child_node(get_label_path("rowcount") ,tostring(usercount) ,get_label_path("data"))

	local ps = math.floor(tonumber(page_size))
	local pn = math.floor(tonumber(page_no))

	if usercount % ps == 0 then
		pc = usercount / ps
	else
		pc = math.floor(usercount / ps) + 1
	end

	if (pn + 1) > pc then
		pn = pc - 1
	else 
		if pn < 0 then
			pn = 0
		end
	end	
	
	xml_opt:add_child_node(get_label_path("pagecount") ,tostring(math.floor(pc)) ,get_label_path("data"))
	xml_opt:add_child_node(get_label_path("pageno") ,tostring(math.floor(pn)) ,get_label_path("data"))
	mysql_opt:release_res()

	sql = "select id, name,reality_name, register_time, is_allow_login, login_count, last_login_ip,last_login_time, "
	sql = sql.."is_online, is_actived, default_identity, soft_type, soft_owner_id,soft_user_id,site_owner_id,"
	sql = sql.."company_name, email, telephone, mobile, id_card_number, address, postcode,(select count(1) from t_sites where creater_id = t1.id) "
	sql = sql.."as 'count_create_site', (select count(1) from t_users t2 "
	sql = sql.."where t2.creater_id = t1.id) as 'count_create_user',creater_id from t_users t1 where (soft_owner_id = "..eims_safety(userid).." or soft_user_id = "..eims_safety(userid)
	sql = sql.." or site_owner_id = "..eims_safety(userid).." or creater_id = "..eims_safety(userid)..") and `id` <> "..eims_safety(userid)

	if readonley_creater == "1" then
		sql = sql.." and (creater_id = "..eims_safety(userid).." and `id` <> "..eims_safety(userid)..")"
	end
	if condition ~= "0" then
		sql = sql.." and ("..eims_safety(condition)..")"
	end

	sql = sql.." order by `id` limit "..tostring(math.floor(pn * ps))..", "..tostring(ps)

	logger:WriteLog("message 215, exe sql :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.RUNTIME)

	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local sitecount = mysql_opt:get_row_count()
	local dl = get_label_path("data")
	local user = get_label_path("user")
	local users = user.."s"
	xml_opt:add_child_node(users, "", dl)
	for i = 0, sitecount - 1 do
		local p = dl.."/"..users.."/"..user..tostring(i)
		xml_opt:add_child_node(user..tostring(i), "", dl.."/"..users)
		xml_opt:add_child_node(get_label_path("id"), 				mysql_opt:get_query_result(i, "id"), 				p)
		xml_opt:add_child_node(get_label_path("name"), 				mysql_opt:get_query_result(i, "name"), 				p)
		xml_opt:add_child_node(get_label_path("reality_name"), 		mysql_opt:get_query_result(i, "reality_name"), 		p)
		xml_opt:add_child_node(get_label_path("register_time"), 	mysql_opt:get_query_result(i, "register_time"), 	p)
		xml_opt:add_child_node(get_label_path("is_allow_login"), 	mysql_opt:get_query_byte_result(i, "is_allow_login"), p)
		xml_opt:add_child_node(get_label_path("login_count"), 		mysql_opt:get_query_result(i, "login_count"), 		p)
		xml_opt:add_child_node(get_label_path("last_login_time"), 	mysql_opt:get_query_result(i, "last_login_time"), 	p)
		xml_opt:add_child_node(get_label_path("last_login_ip"), 	mysql_opt:get_query_result(i, "last_login_ip"), 	p)
		xml_opt:add_child_node(get_label_path("is_online"), 		mysql_opt:get_query_byte_result(i, "is_online"), 	p)
		xml_opt:add_child_node(get_label_path("is_actived"), 		"1", 												p)
		xml_opt:add_child_node(get_label_path("default_identity"), 	mysql_opt:get_query_result(i, "default_identity"), 	p)
		xml_opt:add_child_node(get_label_path("soft_type"), 		mysql_opt:get_query_result(i, "soft_type"), 		p)
		xml_opt:add_child_node(get_label_path("soft_owner_id"), 	mysql_opt:get_query_result(i, "soft_owner_id"), 	p)
		xml_opt:add_child_node(get_label_path("soft_user_id"), 		mysql_opt:get_query_result(i, "soft_user_id"), 		p)
		xml_opt:add_child_node(get_label_path("site_owner_id"), 	mysql_opt:get_query_result(i, "site_owner_id"), 	p)
		xml_opt:add_child_node(get_label_path("company_name"), 		mysql_opt:get_query_result(i, "company_name"), 		p)
		xml_opt:add_child_node(get_label_path("email"), 			mysql_opt:get_query_result(i, "email"), 			p)
		xml_opt:add_child_node(get_label_path("telephone"), 		mysql_opt:get_query_result(i, "telephone"), 		p)
		xml_opt:add_child_node(get_label_path("mobile"), 			mysql_opt:get_query_result(i, "mobile"), 			p)
		xml_opt:add_child_node(get_label_path("id_card_number"), 	mysql_opt:get_query_result(i, "id_card_number"), 	p)
		xml_opt:add_child_node(get_label_path("address"), 			mysql_opt:get_query_result(i, "address"), 			p)
		xml_opt:add_child_node(get_label_path("postcode"), 			mysql_opt:get_query_result(i, "postcode"), 			p)
		xml_opt:add_child_node(get_label_path("count_create_site"), mysql_opt:get_query_result(i, "count_create_site"), p)
		xml_opt:add_child_node(get_label_path("count_create_user"), mysql_opt:get_query_result(i, "count_create_user"), p)
		xml_opt:add_child_node(get_label_path("creater_id"), 		mysql_opt:get_query_result(i, "creater_id"), 		p)
	end
	mysql_opt:release_res()

	return xml_opt:create_xml_string()

end

eims_owner_del_user = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local ownerid = xml_opt:get_node_value(get_label_path("data", "soft_owner_id"))
	local loginid = xml_opt:get_node_value(get_label_path("data", "soft_login_id"))
	local deleteid = xml_opt:get_node_value(get_label_path("data", "delete_user_id"))
	if check_soft_owner(mysql_opt, instruction, ownerid, loginid) == false then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在或没有权限")
	end
	--print("a")
	local sql = "update t_users set is_erased = 1 where id = "..eims_safety(deleteid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()

end

eims_update_user_login_state = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local allowlogin = xml_opt:get_node_value(get_label_path("data", "allow_login"))

	local sql = "select 1 from t_users where `id` = "..eims_safety(userid).." or `mobile` = "..eims_safety(userid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end
	mysql_opt:release_res()

	sql = "update t_users set is_allow_login = "..eims_safety(allowlogin).." where `id` = "..eims_safety(userid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end


eims_only_verify_mobile = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local mobile = xml_opt:get_node_value(get_label_path("data", "mobile"))

	local sql = "select `name` from t_users where `id` = "..eims_safety(userid).." or `mobile` = '"..eims_safety(mobile).."'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end
	local name = mysql_opt:get_query_result(0, "name")
	mysql_opt:release_res()

	local vcode = tool:get_rand_num(6)
	sql = "insert into t_mobile_verifying (user_id, mobile, verify_code, try_time) "
	sql = sql.."values ("..eims_safety(userid)..", '"..eims_safety(mobile).."', '"..eims_safety(vcode).."', now())"
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local body = "尊敬的犀牛云["
    body = body..name
    body = body.."]用户，您好！您在犀牛云申请的手机验证码为："
    body = body..vcode
    body = "，请及时登录平台输入此验证码进行验证！谢谢。"

    sql = "insert into t_send_smss (mobile, body, send_time) values ('"..eims_safety(mobile).."', '"..body.."', now())"
    result = mysql_opt:oper_db_trans_exc_v2(sql, true)
    if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end


eims_only_verify_mobile_2 = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local vcode = xml_opt:get_node_value(get_label_path("data", "verified_code"))

	local sql = "select 1 from t_users where `id` = "..eims_safety(userid).." or `mobile` = '"..eims_safety(userid).."'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end
	mysql_opt:release_res()

	sql = "select `verify_code` from t_mobile_verifying where user_id = "..eims_safety(userid).." order by `id` desc limit 0, 1"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "校验码错误")
	end
	local ovcode = mysql_opt:get_query_result(0, "verify_code")
	mysql_opt:release_res()

	if ovcode ~= vcode then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "校验码错误")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end


eims_email_verify = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local email = xml_opt:get_node_value(get_label_path("data", "email"))
	local sql = "select `name` from t_users where `id` = "..eims_safety(userid).." or `mobile` = '"..eims_safety(userid).."'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end

	local name = mysql_opt:get_query_result(0, "name")
	mysql_opt:release_res()

	local vcode = tool:get_rand_num(6)
	sql = "insert into t_email_verifying (user_id, email, verify_code, try_time) "
	sql = sql.."values ("..eims_safety(userid)..", '"..eims_safety(email).."', '"..vcode.."', now())"
	result = mysql_opt:oper_db_trans_exc_v2(sql, false)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	local subject = "尊敬的犀牛云用户，您好！您在犀牛云申请的 Email 验证码，请查收！"
    local body = "尊敬的犀牛云["..name
    body = body.."]用户，您好：<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;您在犀牛云申请的 Email 验证码为 "..vcode
    body = body.."，请及时登录平台输入此验证码进行验证！谢谢。"

    sql = "insert into t_send_emails (email, subject, body, send_time) values "
    sql = sql.."('"..eims_safety(email).."', '"..subject.."', '"..body.."', now())"
    result = mysql_opt:oper_db_trans_exc_v2(sql, true)
	if result < 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end

eims_email_verify_2 = function ( xml_opt, mysql_opt )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local vcode = xml_opt:get_node_value(get_label_path("data", "verified_code"))
	local sql = "select `name` from t_users where `id` = "..eims_safety(userid).." or `mobile` = '"..eims_safety(userid).."'"
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户不存在")
	end
	mysql_opt:release_res()

	sql = "select `verify_code` from t_email_verifying where user_id = "..eims_safety(userid).." order by `id` desc limit 0, 1"
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	if mysql_opt:get_row_count() <= 0 then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "校验码错误")
	end
	local ovcode = mysql_opt:get_query_result(0, "verify_code")
	mysql_opt:release_res()
	
	if ovcode ~= vcode then
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "校验码错误")
	end

	sql = "update t_users set email_verified = 1 where id = "..eims_safety(userid)
	result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	return xml_opt:create_xml_string()
end

