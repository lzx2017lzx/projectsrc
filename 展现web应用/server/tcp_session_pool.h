
#ifndef __EIMS_SESSION_POOL_H_INC__
#define __EIMS_SESSION_POOL_H_INC__

#include <boost/asio.hpp>
#include <vector>
#include <boost/noncopyable.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/ptr_container/ptr_container.hpp>

namespace lizongxin
{
	namespace tcp
	{
		///用户连接处理池
		class sessionpool
			: private boost::noncopyable
		{
		public:
			///构造
			explicit sessionpool(std::size_t pool_size);
			///析构
			~sessionpool();
			///运行
			void run();
			///停止
			void stop();
			///获取io_service对象
			boost::asio::io_service& get_io_service();

		private:
			typedef boost::shared_ptr<boost::asio::io_service> io_service_ptr;
			typedef boost::shared_ptr<boost::asio::io_service::work> work_ptr;

			///io_service指针集合
			std::vector<io_service_ptr> m_io_services;
			///任务，用于保持io_service
			std::vector<work_ptr> m_work;
			///
			std::size_t m_next_io_service;
		};

	} // namespace network
} // namespace lizongxinls

#endif




