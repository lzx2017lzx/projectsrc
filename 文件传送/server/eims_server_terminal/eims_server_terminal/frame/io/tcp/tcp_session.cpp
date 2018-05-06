#include "tcp_session.h"
#include <vector>
#include <boost/bind.hpp>

namespace eims
{
	namespace tcp
	{
		///构造
		session::session(boost::asio::io_service& io_service)
			: socket_(io_service)
		{
			data_ = NULL;
			result_data = NULL;
		}

		///析构
		session::~session()
		{
			socket_.close();
			if(data_ != NULL)
			{
				delete data_;
				data_ = NULL;
			}
			if(result_data != NULL)
			{
				delete result_data;
				result_data = NULL;
			}
		}

		///获取网络套接字
		boost::asio::ip::tcp::socket& session::socket()
		{
			return socket_;
		}

		///入口函数，会读取前四个字节
		void session::start()
		{
			//获取处理句柄
			data_ = new char[4];

			boost::asio::async_read(socket_,
									boost::asio::buffer(data_, 4),
									boost::bind(&session::handle_read_first, this,
												boost::asio::placeholders::error,
												boost::asio::placeholders::bytes_transferred));
		}

		///读取消息前四个字节，表示长度
		void session::handle_read_first(const boost::system::error_code& error, size_t bytes_transferred)
		{
			Global::logger->write_log("accepting message length.", eLogLv.DEBUG);
			if (error)
			{
				string log = "Handle read first failed. reason is :" + error.message();
				Global::logger->write_log(log, eLogLv.RUNTIME);
				if (data_ != NULL) delete[] data_;
				data_ = NULL;
				delete this;
				return;
			}

			Global::logger->write_log("accepted message length.", eLogLv.DEBUG);
			int len = *(int*)data_;
			if (data_ != NULL)  delete[] data_;
			data_ = NULL;

			//前四个字节表示的长度异常，异常消息，可能危害服务器。关闭掉连接
			if( ((unsigned int)len > MessageMaxLength) || (len <= 0))
			{
				string log = "message is too long or receive a bad message";
				Global::logger->write_log(log, eLogLv.WARN);
				delete this;
				return;
			}
			data_ = new char[len];

			boost::asio::async_read(socket_,
									boost::asio::buffer(data_, len),
									boost::bind(&session::handle_read_second, this,
												boost::asio::placeholders::error,
												boost::asio::placeholders::bytes_transferred));
		}

		///读取消息内容
		void session::handle_read_second(const boost::system::error_code& error, size_t bytes_transferred)
		{
			Global::logger->write_log("accepting message content.", eLogLv.DEBUG);
			if (error)
			{
				string log = "Handle read second failed. reason is :" + error.message();
				Global::logger->write_log(log, eLogLv.RUNTIME);
				if (data_ != NULL)  delete[] data_;
				data_ = NULL;
				delete this;
				return;
			}
			Global::logger->write_log("accepted message content.", eLogLv.DEBUG);
			result_len = 0;
			try
			{
				//printf("recv len is: %d\n", bytes_transferred);
				Global::logger->write_log("start deal message.", eLogLv.DEBUG);
				result_data = hm.handle_message(data_, bytes_transferred, &result_len, remote_ip);
				Global::logger->write_log("deal message finish.", eLogLv.DEBUG);
			}
			catch (const std::exception& e)
			{
				string log = "handle message failed. reason is:";
				log.append(e.what());
				Global::logger->write_log(log, eLogLv.ERROR);

				if (data_ != NULL)
					delete[] data_;
				data_ = NULL;

				if(result_data != NULL)
					delete[] result_data;
				result_data = NULL;

				delete this;

				return;
			}

			if (data_ != NULL) delete[] data_;
			data_ = NULL;

			if (result_data == NULL)
			{
				string log = "handle message error. handled result is null";
				Global::logger->write_log(log, eLogLv.ERROR);
				delete this;
				return;
			}
			//send 4 bytes len
			boost::asio::async_write(socket_,
									 boost::asio::buffer(&result_len, 4),
									 boost::bind(&session::handle_write_second, this,
												 boost::asio::placeholders::error,
												 boost::asio::placeholders::bytes_transferred));
		}

		///发送消息内容
		void session::handle_write_second(const boost::system::error_code& error, size_t bytes_transferred)
		{
			Global::logger->write_log("reply message's len send finished.", eLogLv.DEBUG);
			//write the data
			boost::asio::async_write(socket_,
									 boost::asio::buffer(result_data, result_len),
									 boost::bind(&session::handle_write, this,
												 boost::asio::placeholders::error));
		}

		///消息发送完成后的清理
		void session::handle_write(const boost::system::error_code& error)
		{
			if (result_data != NULL) delete[] result_data;
			result_data = NULL;

			if (!error)
			{
				Global::logger->write_log("reply message's content send finished.", eLogLv.DEBUG);
				session::start();
			}
			else
			{
				string log = "handle_write failed. reason is :" + error.message();
				Global::logger->write_log(log, eLogLv.RUNTIME);
				delete this;
			}

		}
		// No new asynchronous operations are started. This means that all shared_ptr
		// references to the Session object will disappear and the object will be
		// destroyed automatically after this handler returns. The Session class's
		// destructor closes the socket.
	} // namespace network
} // namespace eims



