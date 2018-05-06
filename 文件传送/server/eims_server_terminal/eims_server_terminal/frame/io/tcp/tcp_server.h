#ifndef __EIMS3_SERVER_H_INC__
#define __EIMS3_SERVER_H_INC__

#include <iostream>
#include <boost/asio.hpp>
#include <string>
#include <vector>
#include <boost/noncopyable.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/ptr_container/ptr_container.hpp>
#include "tcp_session.h"
#include "tcp_session_pool.h"
#include "../../common/utilitys.h"
#include "../../common/consts.h"

using namespace std;
namespace eims
{
	namespace tcp
	{
		///TCP服务类
		class server: private boost::noncopyable
		{
		public:
			///构造
			explicit server(const std::string& address, const std::string& port,std::size_t io_service_pool_size);
			///析构
			~server();
			///运行服务
			void run();
			///停止服务
			void stop();
			/// 获取状态
			bool get_state(){ return m_ok_; };

		private:
			///开始接收用户连接
			void start_accept();
			///接收连接
			void handle_accept(const boost::system::error_code& e);
			///断开连接
			void handle_stop();


		private:
			///处理池
			sessionpool m_io_service_pool_;
			///信号集合
			boost::asio::signal_set m_signals_;
			///接收适配器
			boost::asio::ip::tcp::acceptor m_acceptor_;
			///当前连入的用户所使用的session
			session_ptr m_current_accept_session_;
			///接收新用户所使用的session
			session* m_new_session_;
			///状态
			bool m_ok_;

		};
		typedef boost::shared_ptr<session> session_ptr;
	}
}

#endif
