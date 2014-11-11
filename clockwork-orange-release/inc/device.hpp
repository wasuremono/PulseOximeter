/**
 * Christopher Di Bella, Kenneth Ng, Zia Nayamuth, Luke Pearson
 *
 * device.hpp
 *
 * interface for comp3601 device
 *
 * 2014, September 30
 */
#ifndef CLOCKWORK_ORANGE_DEVICE_HPP11_INCLUDED
#define CLOCKWORK_ORANGE_DEVICE_HPP11_INCLUDED

#include <dpcutil.h>
#include <dpcdefs.h>
#include <dpcdecl.h>
#include <mutex>
#include <smart_thread.hpp>
#include <utility>
#include <QLabel>
#include <iostream>
#include <condition_variable>
#include <tuple>
#include <atomic>

namespace clockwork_orange
{
    class value_string;

    class device
    {
    private:
        static std::tuple<int, int, int> data;
        static char name[32];
        static unsigned char buffer[1024];
        static std::atomic_bool connected;
        static std::mutex m;
        static int index;
        static std::condition_variable timer;
        
        static int get_reg(unsigned char reg);
        static void get_from_board();
    public:        
        static void connect(value_string& l);
        static bool is_connected() { /*std::lock_guard<std::mutex> lock(m);*/ return connected; }
        
        static std::tuple<int, int, int> get();
        
        static void interrupt();
    };
}

#endif // CLOCKWORK_ORANGE_DEVICE_HPP11_INCLUDED
