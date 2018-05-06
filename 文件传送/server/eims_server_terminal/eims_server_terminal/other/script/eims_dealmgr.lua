--------------------------------------------------------------------
--
--	deal services manager
--
--------------------------------------------------------------------

package.path = package.path ..";./?.lua;../other/script/?.lua;./script/?.lua"
require("eims_log")
require("eims_common")
require("eims_error")
require("eims_message")

----------------------------------------------------
--	get pay detail
--	old: 0x58    通过用户ID 获取用户支付明细
--	new: 702
----------------------------------------------------
eims_get_user_pay_detail = function ( xml_opt, mysql_opt  )
	-- body
	local id, ver, instruction, sign = eims_get_message_base_element ( xml_opt )
	local userid = xml_opt:get_node_value(get_label_path("data", "user_id"))
	local start = xml_opt:get_node_value(get_label_path("data", "start"))
	local getcount = xml_opt:get_node_value(get_label_path("data", "get_count"))

	local sql = "select *,(select count(1) from t_user_pay_details where `user_id` = "..eims_safety(userid)..") all_count "
	sql = sql.."from t_user_pay_details where `user_id` = "..eims_safety(userid).." order by `pay_time` desc limit "..eims_safety(start)..", "..eims_safety(getcount)
	local result = mysql_opt:oper_db(sql)
	if result ~= 0 then
		logger:WriteLog("db error, message is :"..instruction..", sql is :"..sql, EIMS_LOG_LEVEL.ERROR)
		return eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.SYSTEM_ERROR, "服务器响应请求失败")
	end
	local rowcount = mysql_opt:get_row_count()
	if rowcount <= 0 then
		eims_get_error_msg(xml_opt, id, ver, instruction, sign, EIMS_ERROR.LOGIC_ERROR, "用户ID不存在或该用户ID无应用")
	end

	xml_opt = eims_set_message_base_element(xml_opt, id, ver, instruction, sign, EIMS_ERROR.NO_ERROR, "none")
	local dl = get_label_path("data")
	local pay = get_label_path("pay")
	local pays = pay.."s"
	xml_opt:add_child_node(pays, "", dl)
	for i = 0, rowcount - 1 do
		xml_opt:add_child_node(pay..tostring(i), "", dl.."/"..pays)
		local p = dl.."/"..pays.."/"..pay..tostring(i)
        xml_opt:add_child_node( get_label_path("pay_id"), mysql_opt:get_query_result(i, "pay_id"), p)
        xml_opt:add_child_node( get_label_path("order_no"), mysql_opt:get_query_result(i, "order_no"), p)
        xml_opt:add_child_node( get_label_path("app_id"), mysql_opt:get_query_result(i, "application_id"), p)
        xml_opt:add_child_node( get_label_path("pay_time"), mysql_opt:get_query_result(i, "pay_time"), p)
        xml_opt:add_child_node( get_label_path("out_amount"), mysql_opt:get_query_result(i, "out_amount"), p)
        xml_opt:add_child_node( get_label_path("in_amount"), mysql_opt:get_query_result(i, "in_amount"), p)
        xml_opt:add_child_node( get_label_path("pay_type"), mysql_opt:get_query_result(i, "pay_type"), p)
        xml_opt:add_child_node( get_label_path("balance"), mysql_opt:get_query_result(i, "balance"), p)
        xml_opt:add_child_node( get_label_path("order_title"), mysql_opt:get_query_result(i, "order_title"), p)
        xml_opt:add_child_node( get_label_path("description"), mysql_opt:get_query_result(i, "description"), p)
        xml_opt:add_child_node( get_label_path("status"), mysql_opt:get_query_result(i, "status"), p)
        xml_opt:add_child_node( get_label_path("all_count"), mysql_opt:get_query_result(i, "all_count"), p)
	end
	mysql_opt:release_res()
	return xml_opt:create_xml_string()
end
