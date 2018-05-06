--package.path=package.path.."./?.lua";

--module "user"
--require("common")
--
--debug func
function CustomDebugTraceback(msg)
    print("========================================================================")
    print("====================  LUA  ERROR CallStack Trace  ======================")
    print("========================================================================")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("========================================================================")
end

--sqlw="insert into test1(id) values(333)"
create_user = function(sql)
	print("test1")
	print("get string is "..sql)
	--mysql = db_oper.DbOper()
	print("test2")
	--mysql:oper_db(sql)
	--mysql:oper_db(sqlw)
	print("test")
	return 0
end
--xmlmsg="<message><ver>15</ver><instruction>106</instruction><sign>12345</sign><data><userid>111</userid></data></message>"
xml_test = function(xmlmsg)
	print("testxml")
	print("get string is "..xmlmsg)
	local myxml = xml_oper.XML_Oper()
	print("test2")
	myxml:load_xml_data(xmlmsg,"")
	print("test3")
	local userid = myxml:get_node_value("data/user_id")
	print(userid)
	print("test4")
	local mysql = db_oper.DbOper()
	print("test5")
	local sql = "select office_telephone tel from t_users where id = "..userid
	local ret = mysql:oper_db(sql)
	print("test6")
	if(ret ~= 0) then print("error exe sql") end
	if(tonumber(mysql:get_row_count()) <= 0) then print("no data") return "" end
	local retvalue = tostring(mysql:get_query_result(0, "tel"))
	print("test7")
	print(tostring(mysql:get_query_result(0, "tel")))
	print("test8")
	--mysql:oper_db(sqlw)
	print("test")
	return retvalue
end
