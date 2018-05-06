package.path = package.path ..";./?.lua;../other/script/?.lua;./script/?.lua"

require("eims_log")
require("eims_common")
require("eims_authenticate")
require("eims_usermgr")
require("eims_sitemgr")
require("eims_notifymgr")
require("eims_appmgr")
require("eims_basemgr")
require("eims_dealmgr")

require("eims_config")
require("eims_smalllogic")

funcs_map =
{
	--user manager
	["203"] = eims_get_user_state,--ok
	["204"] = eims_set_user_state,--ok
	["205"] = eims_change_password,--ok
	["206"] = eims_reset_password,--ok
	["207"] = eims_get_userid_by_email,--ok
	["208"] = eims_parent_change_child_password,--not ok
	["211"] = eims_get_usr_info,--ok
	["212"] = eims_update_user_info,--ok
	["213"] = eims_owner_del_user,--ok
	["214"] = eims_update_user_login_state,--ok
	["215"]	= eims_get_all_users,--ok
	["220"] = eims_mobile_verify,--ok
	["221"] = eims_mobile_verify_step_2,--ok
	["222"] = eims_email_verify,--ok
	["223"] = eims_email_verify_2,--ok
	["224"] = eims_only_verify_mobile,--ok
	["225"] = eims_only_verify_mobile_2,--ok

	--site manager
	["301"] = eims_edit_site_ftp_info,--ok
	["302"] = eims_get_user_all_sites,--ok
	["303"] = eims_get_owned_all_sites,--ok
	["304"]	= eims_get_used_all_sites,--ok
	["305"] = eims_get_all_users_by_siteid,--ok
	["306"] = eims_change_site_owner,--ok
	["307"] = eims_add_site_user,--ok
	["308"] = eims_remove_site_user,--ok
	["309"] = eims_delete_site,--ok
	["310"] = eims_edit_site_base_info,--ok
	["311"] = eims_edit_site_version_info,--ok
	["312"] = eims_get_site_all_info,--ok
	["313"] = eims_change_site_owner_set_owner_as_user,--ok
	["314"] = eims_update_website_info,--ok
	["315"] = eims_get_groupmember_by_group_or_site_id,--ok
	["316"] = eims_check_is_site_user,--ok
	["317"] = eims_get_site_default_resource,	--not done
	["318"]	= eims_edit_site_info_db,
	["319"] = eims_get_site_function_ver,--ok
	["324"] = eims_apply_mobile_site,--ok
	["325"] = eims_open_close_mobile_site,--ok
	["326"] = eims_set_web_services,--ok
	["327"] = eims_create_site,--ok
	["330"] = eims_get_user_all_sites_as_owner,
	["331"] = eims_get_user_all_sites_as_user,
	["332"] = eims_get_site_versions,

	--notify namager
	["501"] = eims_get_user_notifies,--ok
	["502"] = eims_send_chat_message,--ok
	["503"] = eims_get_chat_message,--ok
	["504"] = eims_get_user_app_notifys,--ok
	["505"] = eims_get_user_app_notifys_readcount,--ok
	["506"] = eims_get_system_notifys_readcount,--ok
	["507"] = eims_get_notify_type,--ok
	["520"]	= eims_get_all_notify_type,

	--auth manager
	["201"] = eims_login,--ok
	["202"] = eims_logout,--ok
	["401"]	= eims_delete_auth_group,--ok
	["402"]	= eims_get_all_group_by_site,--ok
	["403"]	= eims_add_application_instances,--ok
	["404"]	= eims_edit_group_information_by_group_id,--ok
	["405"] = eims_add_user_in_site_group,--ok
	["406"] = eims_delete_user_in_site_group,--ok
	["407"] = eims_set_group_or_user_role,--ok
	["408"] = eims_create_group_by_userid_and_siteid,--ok

	--app manager
	["601"] = eims_get_apps_info,--ok
	["603"] = eims_get_user_release_apps,--ok
	["606"] = eims_get_user_application_apps,--ok
	["607"] = eims_add_app_auth,--ok
	["608"]	= eims_get_app_private_users,--ok
	["612"] = eims_get_user_private_app_list,
	["615"] = eims_get_app_detail,--ok
	["609"] = eims_get_user_all_apps,--ok
	["614"]	= eims_create_app_user,--ok           register
	["613"] = eims_create_soft_owner,--			  register
	["630"]	= emis_get_all_app_id,
	["631"] = eims_get_all_app_type_id,
	["632"] = eims_get_app_types,

	--base server
	["801"] = eims_heart_beat_packet,--ok
	["802"] = eims_get_client_new_ver_and_path,--ok
	["813"] = eims_get_client_new_ver_and_path_db,
	["803"] = eims_get_trade_type_list,--ok
	["804"] = eims_get_ctl_type_list,--ok
	["805"] = eims_get_fun_ctl_list,--ok
	["806"] = eims_get_province_list,--ok
	["807"] = eims_get_city_list,--ok
	["808"] = eims_get_area_list,--ok
	["812"] = eims_get_server_ver_and_type,--ok

	--deal manager
	["702"]	= eims_get_user_pay_detail
}

-----------------------------------------------
--
--	message Entrance
--
-----------------------------------------------
eims_main = function(xml_data, clientid, ip)
	--lua oper load this file one time while start
	if g_xml_oper == nil then
		g_xml_oper = xml_oper.xml_oper()
	end
	if g_mysql_oper == nil then
		g_mysql_oper = db_oper.db_oper()
	end

	local loadresult = g_xml_oper:load_xml_data(xml_data, get_label_path("message"))
	if loadresult ~= 0 then
		g_xml_oper:clear_all_nodes()
		logger:WriteLog("load xmldata error, error code "..tostring(math.floor(loadresult)), EIMS_LOG_LEVEL.ERROR)
		return "<msg><id>0</id><ver>15</ver><ic>0</ic><sn>0</sn><el>0</el><dt><ed>消息格式错误</ed></dt></msg>"
	end

	local iz = g_xml_oper:get_node_value(get_label_path("instruction"))
	g_xml_oper:add_child_node(get_label_path("client_id"), clientid, get_label_path("data"))

	if iz == "" or funcs_map[iz] == nil then
		logger:WriteLog("have not match func. instruction is "..iz, EIMS_LOG_LEVEL.ERROR)
		local ret = eims_trans_msg_2_error_response(g_xml_oper, xml_data, EIMS_ERROR.LOGIC_ERROR, "非法的请求")
		g_xml_oper:clear_all_nodes()
		return ret
	end
	--if login or logout then add ip to the message
	if iz == "201" or iz == "202" then
		g_xml_oper:add_child_node(get_label_path("ip"), ip, get_label_path("data"))
	end
	--Analysis instruction to choose the router
	if iz == "201" or iz == "206" or iz == "207" or iz == "614" or iz == "613" or iz == "812" or iz == "802" or iz == "813" then
		local loginret = funcs_map[iz](g_xml_oper, g_mysql_oper)
		g_xml_oper:clear_all_nodes()
		logger:WriteLog(clientid.." is visited, instruction is "..iz, EIMS_LOG_LEVEL.DEBUG)
		return loginret
	else
		--check is login
		local uid = is_user_online(g_mysql_oper, g_xml_oper, clientid, instruction)
		if uid == "0" then
			g_xml_oper:clear_all_nodes()
			g_mysql_oper:release_res()
			return eims_trans_msg_2_error_response(g_xml_oper, xml_data, EIMS_ERROR.LOGIC_ERROR, "非法的请求")
		else
			--
			-- here can add user_id to message
		end

		--update user operation time
		if update_user_latest_login(g_mysql_oper, g_xml_oper, clientid, instruction) ~= true then
			g_xml_oper:clear_all_nodes()
			logger:WriteLog("update user latest time failed .", EIMS_LOG_LEVEL.ERROR)
			return eims_trans_msg_2_error_response(g_xml_oper, xml_data, EIMS_ERROR.SYSTEM_ERROR, "请求失败，请重试")
		end
		logger:WriteLog(clientid.." is visited, instruction is "..iz, EIMS_LOG_LEVEL.DEBUG)
	end

	--deal message
	local response_message = funcs_map[iz](g_xml_oper, g_mysql_oper)

	--release xml obj and mysql obj
	g_xml_oper:clear_all_nodes()
	g_mysql_oper:release_res()

	return response_message
end
