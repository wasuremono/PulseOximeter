/**
 * Christopher Di Bella, Kenneth Ng, Zia Nayamuth, Luke Pearson
 *
 * device.hpp
 *
 * implementation for comp3601 device
 *
 * 2014, September 30
 */

#include <device.hpp>
#include <value.hpp>
#include <sstream>
#include <mutex>

using std::ostringstream;
using std::make_tuple;

namespace clockwork_orange
{
    bool read = false;
    std::tuple<int, int, int> device::data{ make_tuple(0, 0, 0) };
    char device::name[32];
    unsigned char device::buffer[1024];
    std::atomic_bool device::connected{ false };
    std::mutex device::m;
    std::condition_variable device::timer;
    
    void device::connect(value_string& status)
    {
        if (connected == false)
        {
            ERC erc;
            int id;
            if (!DpcInit(&erc))
            {
                 status.update("Unable to initialise");
                return;
            }

            id = DvmgGetDefaultDev(&erc);
            if (id == -1)
            {
                 status.update("No default device");
            }
            
            DvmgGetDevName(id, name, &erc);
            
            ostringstream oss;
            oss << name << " connected";
            status.update(oss.str().c_str());
            
            buffer[0] = 'a';
            //putReg(1, buffer, sizeof(buffer));
            connected = true;
            
            std::get<0>(data) = 0;
            std::get<1>(data) = 0;
            std::get<2>(data) = 0;
        }
    }
    
    std::tuple<int, int, int> device::get()
    {
        std::unique_lock<std::mutex> lock(m);
        timer.wait(lock, [&] { return read; });
        read = false;
        timer.notify_one();
        return data;
    }
    
    void device::interrupt()
    {
        while (is_connected())
        {
            get_from_board();
        }
    }
    
    void device::get_from_board()
    {
        std::unique_lock<std::mutex> lock(m);
        timer.wait(lock, [&] { return !read; });
        read = true;
        timer.notify_one();
        std::get<0>(data) = get_reg(1);
        int i = 0;
        while(i < 1000){
            i ++;
        }
        std::get<1>(data) = get_reg(3);
        i = 0;
        while(i < 1000){
            i ++;
        }
        std::get<2>(data) = get_reg(5);
    }
    
    int device::get_reg(unsigned char reg)
    {
        unsigned char b;
        ERC		erc;
        HANDLE	hif;

        if (!DpcOpenData(&hif, name, &erc, nullptr))
        {
            connected = false;
            return -1;
        }

        if (!DpcGetReg(hif, reg, &b, &erc, nullptr))
        {
            DpcCloseData(hif,&erc);
            connected = false;
            return reg * -2;
        }

        erc = DpcGetFirstError(hif);
        DpcCloseData(hif, &erc);

        if (erc == ercNoError)
        {
            return b;
        }
        else
        {
            connected = false;
            return -3;
        }
    }
}
