#ifndef __EIMS_SESSION_H_INC__
#define __EIMS_SESSION_H_INC__

#include <boost/asio.hpp>
#include <boost/array.hpp>
#include <boost/noncopyable.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>
#include "../../../eims/protocols/message_handler.h"

using namespace eims::protocols;

namespace eims
{
	namespace tcp
	{
		///客户端处理类
		class session
			: public boost::enable_shared_from_this<session>,
		private boost::noncopyable
		{
		public:
			///构造
			explicit session(boost::asio::io_service& io_service);
			///析构
			~session();
			///获取通讯套接字
			boost::asio::ip::tcp::socket& socket();
			///入口
			void start();

			string remote_ip;

		private:
			///发送消息后的清理工作
			void handle_write(const boost::system::error_code& error);
			///读取表示消息长度的前四字节
			void handle_read_first(const boost::system::error_code& error, size_t bytes_transferred);
			///读取消息内容
			void handle_read_second(const boost::system::error_code& error, size_t bytes_transferred);
			///发送消息内容
			void handle_write_second(const boost::system::error_code& error, size_t bytes_transferred);

		private:
			///消息处理句柄
			CHandleMessage hm;
			///通讯套接字
			boost::asio::ip::tcp::socket socket_;
			///接收的消息内容
			char* data_;
			///发送的消息内容
			char* result_data;
			///发送的消息长度（不包含前四个表示消息长度的字节）
			size_t result_len;
		};

		typedef boost::shared_ptr<session> session_ptr;

	} // namespace network
} // namespace eims

#endif
