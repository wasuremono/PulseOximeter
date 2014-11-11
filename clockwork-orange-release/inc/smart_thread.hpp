/**
 * Christopher Di Bella, Kenneth Ng, Zia Nayamuth, Luke Pearson
 *
 * smart_thread.hpp
 *
 * implementation for comp3601 thread class
 *
 * 2014, September 30
 */

#ifndef CLOCKWORK_ORANGE_SMART_THREAD_HPP11_INCLUDED
#define CLOCKWORK_ORANGE_SMART_THREAD_HPP11_INCLUDED

#include <thread>

namespace clockwork_orange
{
    template <bool detach = false>
    class smart_thread
    {
    private:
        std::thread m_thread;
        
        smart_thread(const smart_thread&) = delete;
        smart_thread& operator=(const smart_thread&) = delete;
    public:
        explicit smart_thread(std::thread t) : m_thread(std::move(t))
        {
            if (m_thread.joinable() == false)
                throw std::logic_error("no thread");
        }
        
        smart_thread(smart_thread&& original) : m_thread(std::move(original.m_thread)) { }
        
        smart_thread& operator=(smart_thread&& rhs)
        {
            if (&rhs != this)
            {
                m_thread = std::move(rhs.m_thread);
            }
            
            return *this;
        }
        
        ~smart_thread()
        {
            if (detach)
            {
                m_thread.detach();
            }
            else
            {
                m_thread.join();
            }
        }
    };
    
    typedef smart_thread<false> joinable_thread;
    typedef smart_thread<true>  detachable_thread;
}

#endif // CLOCKWORK_ORANGE_SMART_THREAD_HPP11_INCLUDED
