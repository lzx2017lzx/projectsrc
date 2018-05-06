#include "tcp_session.h"
#include <vector>
#include <boost/bind.hpp>

namespace lizongxin
{
	namespace tcp
	{
		///构造
		session::session(boost::asio::io_service& io_service)
			: socket_(io_service),hm()
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
			if (error)
			{
				string log = "Handle read first failed. reason is :" + error.message();
				if (data_ != NULL) delete[] data_;
				data_ = NULL;
				delete this;
                LOG("tcp_session","handle_read_first fail","log:%s",log.c_str());
				return;
			}

			int len = *(int*)data_;
			if (data_ != NULL)  delete[] data_;
			data_ = NULL;
            len=ntohl(len);
            LOG("tcp_session","handle_read_first","len:%d",len);
            printf("len:%d\n",len);

			//前四个字节表示的长度异常，异常消息，可能危害服务器。关闭掉连接
			if( ((unsigned int)len > MessageMaxLength) || (len <= 0))
			{
				string log = "message is too long or receive a bad message";
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
			if (error)
			{
				string log = "Handle read second failed. reason is :" + error.message();
				if (data_ != NULL)  delete[] data_;
				data_ = NULL;
				delete this;
				return;
			}
			result_len = 0;
			try
			{
				printf("tcp_server is working data_:%s\n", data_);
				result_data = hm.handle_message(data_,strlen(data_), &result_len, remote_ip);
                result_len=strlen(result_data);
                cout<<"result_len:"<<result_len<<endl;
                result_len=htonl(result_len);
                printf("result_data:%s\n",result_data);
	//			result_data = hm.handle_message(NULL,0, &result_len, remote_ip);
                #if 0
                result_data=new char[15];
                strcpy(result_data,"server respond");
                result_len=strlen(result_data);
                cout<<"result_len:"<<result_len<<endl;
                result_len=htonl(result_len);
                #endif
                
			}
			catch (const std::exception& e)
			{
				string log = "handle message failed. reason is:";
                printf("exception e:%s--------------\n",e.what());

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
            
            try
            {
			if (result_data == NULL)
			{
				if (data_ != NULL)
					delete[] data_;
				data_ = NULL;
				string log = "handle message error. handled result is null";
				delete this;
				return;
			}
            }
			catch (const std::exception& e)
			{
                cout<<"e.what():"<<e.what()<<endl;;
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
			//write the data
			boost::asio::async_write(socket_,
									 boost::asio::buffer(result_data, ntohl(result_len)),
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
				session::start();
                printf("session:start\n");
			}
			else
			{
				string log = "handle_write failed. reason is :" + error.message();
                printf("session:fail\n");
				delete this;
			}

		}
		// No new asynchronous operations are started. This means that all shared_ptr
		// references to the Session object will disappear and the object will be
		// destroyed automatically after this handler returns. The Session class's
		// destructor closes the socket.
	} // namespace network
} // namespace lizongxin




