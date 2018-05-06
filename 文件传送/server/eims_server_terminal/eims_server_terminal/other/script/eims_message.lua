------------------------------------------------------------------------------
--
--	message manager module
--
------------------------------------------------------------------------------



package.path = package.path ..";./?.lua;../other/script/?.lua;./script/?.lua"

require("eims_log")
require("eims_messagemap")

--request message format
message_base_request_style = "<msg><id>111</id><ver>15</ver><ic>201</ic><sn>12345</sn><dt><cli>111</cli></dt></msg>"

--response message format
message_base_response_style = "<msg><id>111</id><ver>15</ver><ic>201</ic><sn>12345</sn><el></el><dt></dt></msg>"


---------------------------------------------------
--
--	
--
---------------------------------------------------
get_label_path = function ( label1, ... )
	-- body
	local labels_path = message_labels[label1]
	 for i, v in ipairs{...} do
 		labels_path = labels_path .. "/" .. message_labels[v]
  	 end
  	return labels_path
end

---------------------------------------------------
--
--	
--
---------------------------------------------------
eims_get_error_msg = function(xml_handle, id, ver, instr, sign, errlev, error_des)
	xml_handle:load_xml_data(message_base_response_style, get_label_path("message"))
	xml_handle:set_node_value(get_label_path("errlev"), errlev)
	xml_handle:set_node_value(get_label_path("id"), id)
	xml_handle:set_node_value(get_label_path("ver"), ver)
	xml_handle:set_node_value(get_label_path("instruction"), instr)
	xml_handle:set_node_value(get_label_path("sign"), sign)
	xml_handle:add_child_node(get_label_path("error_desc"), error_des,get_label_path("data"))
	return xml_handle:create_xml_string()
end

---------------------------------------------------
--
--	
--
---------------------------------------------------
eims_trans_msg_2_error_response = function ( xml_handle, xml_data_src , errlev, desc)
	-- body
	local id = xml_handle:get_node_value(get_label_path("id"))
	local ver = xml_handle:get_node_value(get_label_path("ver"))
	local instruction = xml_handle:get_node_value(get_label_path("instruction"))
	local sign = xml_handle:get_node_value(get_label_path("sign"))
	return eims_get_error_msg(xml_handle, id, ver, instruction, sign, errlev, desc)
end

---------------------------------------------------
--
--	get message base format elements
--
---------------------------------------------------
eims_get_message_base_element = function ( xml_opt )
	-- body
	local ver = xml_opt:get_node_value(get_label_path("ver"))
	local id = xml_opt:get_node_value(get_label_path("id"))
	local instruction = xml_opt:get_node_value(get_label_path("instruction"))
	local sign = xml_opt:get_node_value(get_label_path("sign"))
	return id, ver, instruction, sign
end

---------------------------------------------------
--
--	set message base format elements
--
---------------------------------------------------
eims_set_message_base_element = function ( xml_opt , id, ver, instr, sign, errlev, err_desc)
	-- body
	xml_opt:load_xml_data(message_base_response_style, get_label_path("message"))
	xml_opt:set_node_value(get_label_path("errlev"), errlev)
	xml_opt:set_node_value(get_label_path("id"), id)
	xml_opt:set_node_value(get_label_path("ver"), ver)
	xml_opt:set_node_value(get_label_path("sign"), sign)
	xml_opt:set_node_value(get_label_path("instruction"), instr)
	xml_opt:add_child_node(get_label_path("error_desc"), err_desc, get_label_path("data"))
	return xml_opt
end

eims_system_error = function ( thing )
	-- body

end