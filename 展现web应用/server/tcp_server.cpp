#include "tcp_server.h"
#include <boost/bind.hpp>

namespace lizongxin
{
	namespace tcp
	{
		///构造
		server::server(const std::string& address, const std::string& port,std::size_t m_io_service_poolsize)
			: m_io_service_pool_(m_io_service_poolsize),
			m_signals_(m_io_service_pool_.get_io_service()),
			m_acceptor_(m_io_service_pool_.get_io_service()),
			m_current_accept_session_(),
			m_ok_(false)
		{
			// Register to handle the signals that indicate when the server should exit.
			// It is safe to register for the same signal multiple times in a program,
			// provided all registration for the specified signal is made through Asio.
			m_signals_.add(SIGINT);
			m_signals_.add(SIGTERM);
			#if defined(SIGQUIT)
			m_signals_.add(SIGQUIT);
			#endif // defined(SIGQUIT)
			m_signals_.async_wait(boost::bind(&server::handle_stop, this));

			// Open the acceptor with the option to reuse the address (i.e. SO_REUSEADDR).

			boost::asio::ip::tcp::resolver resolver(m_acceptor_.get_io_service());
			boost::asio::ip::tcp::resolver::query query(address, port);
			boost::asio::ip::tcp::endpoint endpoint = *resolver.resolve(query);
			m_acceptor_.open(endpoint.protocol());
			m_acceptor_.set_option(boost::asio::ip::tcp::acceptor::reuse_address(false));
			m_acceptor_.bind(endpoint);
			m_acceptor_.listen();

			start_accept();
		}

		///析构
		server::~server()
		{
		}

		///运行服务
		void server::run()
		{
			m_io_service_pool_.run();
		}

		///开始接收连接
		void server::start_accept()
		{
			m_new_session_ = new session(m_io_service_pool_.get_io_service());
			m_acceptor_.async_accept(m_new_session_->socket(),
									boost::bind(&server::handle_accept, this,
												boost::asio::placeholders::error));
		}

		///接收用户连接
		void server::handle_accept(const boost::system::error_code& e)
		{
			// if accept failed, the session's socket will be closed,
			// then session will delete itself.
			if (!e)
			{
				string log = "";
				try
				{
					m_new_session_->remote_ip = m_new_session_->socket().remote_endpoint().address().to_string();
				}
				catch(const std::exception& e)
				{
					m_new_session_->remote_ip = "0.0.0.0";
				}
                LOG("tcp_server","handle_accept","%s,ip:%s","before start",m_new_session_->remote_ip);
				m_new_session_->start();
			}
			else
			{
				string log = "Start to accept failed.reason is :" + e.message();
			}
			start_accept();
		}

		///停止服务
		void server::handle_stop()
		{
			m_io_service_pool_.stop();
		}

		///停止服务
		void server::stop()
		{
			handle_stop();
		}
	} // namespace network
} // namespace lizongxin


