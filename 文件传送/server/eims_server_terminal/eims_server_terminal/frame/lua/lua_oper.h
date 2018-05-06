/*****************************************
 *
 *
 * \file    lua_oper.h
 *
 * \brief
 *
 *
 ****************************************/
#ifndef __LUA_OPER_H_INC__
#define __LUA_OPER_H_INC__
#define CALL_OK 	0
#define CALL_BAD 	1

#include "lua_callcpp.h"
#include "../common/meta.h"

#define PTR_RELEASE(x)          {delete (x); x=NULL;};
#define PTR_ARRAY_RELEASE(x)    {delete [](x);x=NULL;}

using namespace eims::meta;

namespace eims
{
	namespace lua
	{
		///LUA虚拟机类
		class lua_oper
		{
		public:
			///构造
			lua_oper();
			///析构
			~lua_oper();

			///初始化
			bool initial();

			///获取LUA虚拟机
			lua_State* get_lua_state() const
			{
				return m_L;
			}

			///重置LUA脚本文件夹路径
			void reset_scipt_folder(const char* script_folder);
			///设置LUA入口文件
			void set_entrance_file(const char* filename);
			///加载LUA文件
			int load_lua_file();
			///调用脚本中的函数
			int call_lua_func_ex(const char* func_name, const TArgPool& ArgPoolObj);
			///调用脚本中的函数
			int call_lua_func(const char* func_name, const TArgPool& ArgPoolObj);
			///获取调用LUA函数中的返回值
			void get_return_value(string& sr);
			///获取调用LUA函数中的返回值
			void get_return_value(char* sr, size_t* alreay_size);
			///清空LUA堆栈
			void clear();
			///关闭LUA虚拟机
			void close_lua();
			///获取当前LUA堆栈的元素个数（暂未使用）
			int get_current_stack_length();
			///设置当前LUA堆栈的元素个数（暂未使用）
			void set_stack_length(int len);

		public:
			///当前堆栈的最大元素数
			int m_max_stack_length;
			///错误描述
			string m_err_desc;

		private:
			///LUA虚拟机
			lua_State* m_L;
			///脚本位置全路径
			string m_script_full_path;
		};
	}
}


#endif
