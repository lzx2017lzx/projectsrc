
package.path = package.path ..";./?.lua;../other/script/?.lua;./script/?.lua"

require("eims_config")
require("eims_log")

tool = tools.Tools()

--debug func
function CustomDebugTraceback(msg)
    print("========================================================================")
    print("====================  LUA  ERROR CallStack Trace  ======================")
    print("========================================================================")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("========================================================================")
    local log = "LUA  ERROR :"..tostring(msg).."\n"..debug.traceback()
    if config.open_log_record == 1 then
    	logger:WriteLog(tostring(msg)..tostring(log), EIMS_LOG_LEVEL.ERROR)
    end
end

------------------------------------------
--  
--
------------------------------------------
eims_safety = function ( src )
	-- body
	src = string.gsub(src, "delete", "delete_")
	src = string.gsub(src, "exec", "exec_")
	src = string.gsub(src, "master", "master_")
	src = string.gsub(src, "truncate", "truncate_")
	src = string.gsub(src, "declare", "declare_")
	src = string.gsub(src, "create", "create_")
	src = string.gsub(src, "xp_", "xp-")
	return src
end

--------------------------------------------
--   @data 2013-04-20
--   @description 注册EIMS ID 是否靓号
--------------------------------------------
is_beautiful = function ( eims_id )
    -- body
    local n1 = (eims_id / 10000)
    local n2 = (eims_id / 1000) % 10
    local n3 = (eims_id / 100) % 10
    local n4 = (eims_id / 10) % 10
    local n5 = eims_id % 10
    --- 顺号 >= 4
    if (n1+1) == n2 and (n1+2) == n3 and (n1+3) == n4 then
        return true
    end
    if (n2+1) == n3 and (n2+2) == n4 and (n2+3) == n5 then
        return true
    end
    -- 叠号 >= 3
    if n1 == n2 and n1 == n3 then
        return true
    end
    if n2 == n3 and n2 == n4 then
        return true
    end
    if n3 == n4 and n4 == n5 then
        return true
    end
    -- 双叠
    if n1 == n2 and n4 == n5 then
        return true
    end
    if n2 == n3 and n4 == n5 then
        return true
    end
    return false
end


