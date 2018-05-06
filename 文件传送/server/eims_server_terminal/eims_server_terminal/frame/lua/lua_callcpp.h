
#ifndef __LUA_CALL_CPP_H_INC__
#define __LUA_CALL_CPP_H_INC__

#include <string>
#include <vector>

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

using namespace std;
namespace eims
{
	namespace lua
	{
		///传给LUA的参数的父类
		class TArg
		{
		public:
			TArg() {}
			virtual void pushvalue(lua_State* L)const = 0;
			virtual ~TArg(){ };
		};


		///传给LUA的整型类参数
		class TArgInt: public TArg
		{
			int m_intv;
		public:
			explicit TArgInt(int v): m_intv(v) {}
			virtual void pushvalue(lua_State* L) const
			{
				lua_pushinteger(L, m_intv);
			}
		};

		///传给LUA的字符串类参数
		class TArgStr: public TArg
		{
			string m_strv;
		public:
			explicit TArgStr(const string& v): m_strv(v) {}
			virtual void pushvalue(lua_State* L) const
			{
				lua_pushstring(L, m_strv.c_str());
			}
		};

		///传给LUA的Bool类参数
		class TArgBool: public TArg
		{
			bool m_boolv;
		public:
			explicit TArgBool(bool v): m_boolv(v) {}
			virtual void pushvalue(lua_State* L) const
			{
				lua_pushboolean(L, m_boolv);
			}
		};


		///传给LUA的参数列表
		class TArgPool
		{
			std::vector<TArg*> m_argList;
		public:
			TArgPool() {}
			void AddArg(int Value);
			void AddArg(const std::string& Str);
			void AddArg(bool Value);
			int Push(lua_State* L)const;
			~TArgPool();
		};
	}
} //end namespace eims

#endif



