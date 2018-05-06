#include <stdexcept>
#include <boost/thread/thread.hpp>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>

#include "tcp_session_pool.h"
#include "tcp_server.h"


namespace eims
{
	namespace tcp
	{

		sessionpool::sessionpool(std::size_t pool_size)
			: m_next_io_service(0)
		{
			if (pool_size == 0)
			{
				pool_size = 10;
			}
			//throw std::runtime_error("sessionpool size is 0");

			// Give all the io_services work to do so that their run() functions will not
			// exit until they are explicitly stopped.
			for (std::size_t i = 0; i < pool_size; ++i)
			{
				io_service_ptr io_service(new boost::asio::io_service);
				work_ptr work(new boost::asio::io_service::work(*io_service));
				m_io_services.push_back(io_service);
				m_work.push_back(work);
			}
		}

		sessionpool::~sessionpool()
		{
		}

		void sessionpool::run()
		{
			// Create a pool of threads to run all of the io_services.
			std::vector<boost::shared_ptr<boost::thread> > threads;
			for (std::size_t i = 0; i < m_io_services.size(); ++i)
			{
				boost::shared_ptr<boost::thread> thread(new boost::thread(
						boost::bind(&boost::asio::io_service::run, m_io_services[i])));
				threads.push_back(thread);
			}

			// Wait for all threads in the pool to exit.
			for (std::size_t i = 0; i < threads.size(); ++i)
				threads[i]->join();
		}

		void sessionpool::stop()
		{
			// Explicitly stop all io_services.
			for (std::size_t i = 0; i < m_io_services.size(); ++i)
				m_io_services[i]->stop();
		}

		boost::asio::io_service& sessionpool::get_io_service()
		{
			// Use a round-robin scheme to choose the next io_service to use.
			boost::asio::io_service& io_service = *m_io_services[m_next_io_service];
			++m_next_io_service;
			if (m_next_io_service == m_io_services.size())
				m_next_io_service = 0;
			return io_service;
		}

	} // namespace network
} // namespace eims
