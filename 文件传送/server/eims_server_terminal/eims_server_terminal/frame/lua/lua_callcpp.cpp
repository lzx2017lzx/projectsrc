#include "lua_callcpp.h"

namespace eims
{
	namespace lua
	{
		///添加参数到参数列表
		void TArgPool::AddArg(int Value)
		{
			TArgInt* pObj = new TArgInt(Value);
			m_argList.push_back(pObj);
		}

		///添加参数到参数列表
		void TArgPool::AddArg(const std::string& Str)
		{
			TArgStr* pObj = new TArgStr(Str);
			m_argList.push_back(pObj);
		}

		///添加参数到参数列表
		void TArgPool::AddArg(bool Value)
		{
			TArgBool* pObj = new TArgBool(Value);
			m_argList.push_back(pObj);
		}

		///添加参数到LUA堆栈
		int TArgPool::Push(lua_State* L)const
		{
			for (size_t i = 0; i < m_argList.size(); i++)
			{
				m_argList[i]->pushvalue(L);
			}
			return m_argList.size();
		}

		///析构
		TArgPool::~TArgPool()
		{
			for (size_t i = 0; i < m_argList.size(); i++)
			{
				delete m_argList[i];
			}
			m_argList.clear();
		}
	}
}



