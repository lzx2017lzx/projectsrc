/*****************************************
 *
 *
 * \file    lua_oper.cpp
 *
 * \brief
 *
 *
 ****************************************/

#include "lua_oper.h"


namespace eims
{
	namespace lua
	{

		extern "C"
		{
			// use swig auto generate api import here:
			extern int luaopen_db_oper(lua_State* L);
			extern int luaopen_xml_oper(lua_State* L);
			extern int luaopen_log_oper(lua_State* L);
			extern int luaopen_tools(lua_State* L);
		};

		lua_oper::lua_oper() : m_script_full_path("")
		{
			m_L = luaL_newstate();
			luaL_openlibs(m_L);
			luaopen_base(m_L);
			luaopen_log_oper(m_L);
			luaopen_xml_oper(m_L);
			luaopen_db_oper(m_L);
			luaopen_tools(m_L);
		}

		lua_oper::~lua_oper()
		{
			clear();
			if(m_L)
			{
				lua_close(m_L);
			}
		}

		void lua_oper::reset_scipt_folder(const char* script_folder)
		{
			m_script_full_path.clear();
			if(script_folder)
				m_script_full_path.append(script_folder);
		}

		void lua_oper::set_entrance_file(const char* filename)
		{
			if(filename)
				m_script_full_path.append(filename);
		}

		int lua_oper::load_lua_file()
		{
			//return value
			// LUA_OK		0
			// LUA_YIELD		1
			// LUA_ERRRUN	2
			// LUA_ERRSYNTAX	3
			// LUA_ERRMEM	4
			// LUA_ERRGCMM	5
			// LUA_ERRERR	6
			// LUA_NOTEXSIST 7
			int ls = luaL_loadfile(m_L, m_script_full_path.c_str());
			if(ls != 0)
			{
				//printf("Load lua file failed. Reason code :%d\n", ls);
				m_err_desc = "Load lua file failed. Reason code :" + longlong2str(ls);
				return ls;
			}
			int lc = lua_pcall(m_L, 0, LUA_MULTRET, 0);
			if(lc != 0)
			{
				m_err_desc = "lua_pcall failed. Reason code :" + longlong2str(lc);
				string err_desc = lua_tostring(m_L,-1);
				printf(err_desc.c_str());
				return lc;
			}
			return 0;
		}

		int lua_oper::call_lua_func(const char* func_name, const TArgPool& ArgPoolObj)
		{
			if(!func_name)
				return -1;
			//将调试函数压入栈中
			lua_getglobal(m_L,"CustomDebugTraceback");
			int errfunc = lua_gettop(m_L);
			//将要被调用的函数压入栈中
			lua_getglobal(m_L,func_name);
			if (lua_isfunction(m_L, -1) )
			{
				int ret = lua_pcall(m_L, ArgPoolObj.Push(m_L), LUA_MULTRET, errfunc);
				if ( 0 == ret)
				{
					return CALL_OK;
				}
				m_err_desc = "call lua function failed";
			}
			else
			{
				m_err_desc = "call lua function failed , error reason :not function";
			}
			return CALL_BAD;
		}

		void lua_oper::close_lua()
		{
			clear();
			if(m_L) lua_close(m_L);
		}

		void lua_oper::get_return_value(string& sr)
		{
			if(lua_isstring(m_L, -1))
			{
				size_t len;
				const char* cr = lua_tolstring(m_L, -1, &len);
				sr.append(cr, len);
			}
			else
			{
				sr = "";
			}
		}

		void lua_oper::clear()
		{
			lua_settop(m_L, 0);
			lua_gc(m_L, LUA_GCRESTART, 0);
		}

		int lua_oper::get_current_stack_length()
		{
			return lua_gettop(m_L);
		}

		void lua_oper::set_stack_length(int len)
		{
			m_max_stack_length = len;
		}
	}
};






