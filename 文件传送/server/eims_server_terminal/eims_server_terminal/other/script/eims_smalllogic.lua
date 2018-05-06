package.path = package.path ..";./?.lua;../other/script/?.lua;./script/?.lua"

require("eims_log")
require("eims_error")

check_id_is_soft_owner = function ( mysql_opt, id )
	-- body
	return true
end

is_user_online = function (mysql_opt, xml_oper, cid, iz)
	-- body
	local sql = "select user_id from t_users_online where unique_id = "..eims_safety(cid)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..iz..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return "0"
	end
	if mysql_opt:get_row_count() <= 0 then
		logger:WriteLog("have no user talk info", EIMS_LOG_LEVEL.INFO)
		return "0"
	end

	local userid = mysql_opt:get_query_result(0, "user_id")
	if userid == "" or userid == "0" then
		logger:WriteLog("user not login", EIMS_LOG_LEVEL.INFO)
		mysql_opt:release_res()
		return "0"
	else
		mysql_opt:release_res()
		return userid
	end
end

update_user_latest_login = function ( mysql_opt, xml_oper, cid, iz )
	-- body
	local sql = "update t_users_online set oper_time=UNIX_TIMESTAMP(now()) where unique_id ="..eims_safety(cid)
	if mysql_opt:oper_db(sql) ~= 0 then
		logger:WriteLog("db error, message is :"..iz..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return false
	end
	return true
end

check_soft_owner = function(mysql_opt, iz, oid, uid)
	local sql = "select id from t_users where soft_owner_id = "..eims_safety(oid).." and id = "..eims_safety(uid)
	--print(sql)
	if mysql_opt:oper_db(sql) < 0 then
		logger:WriteLog("db error, message is :"..iz..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return false
	end
	if mysql_opt:get_row_count() <= 0 then
		return false
	end
	mysql_opt:release_res()
	return true
end