#include <qthread.hpp>

namespace clockwork_orange
{
    qthread::run(main_window* w)
    {
        std::ostringstream oss;
        while (true)
        {
            double average_hr = 0.0, average_o2 = 0.0;
            auto t = std::make_pair(85, 99.8);//device::get();
            
            if (t.first < 0)
            {
                if (t.first == -1)
                {
                    w->m_connectionStatus->setText("Failed to open data");
                }
                else if (t.first == -3)
                {
                    w->m_connectionStatus->setText("An error occurred in the erc");
                }
                else if (t.first % 2 == 0) // register error!
                {
                    auto r = t.first / -2;
                    oss << "Failed to get data from register " << r << ".";
                    w->m_connectionStatus->setText(oss.str().c_str());
                }
                
                break;
            }
            
            for (size_t i = 0; i < 255; ++i)
            {
                w->m_hry[i] = w->m_hry[i + 1];
                w->m_o2y[i] = w->m_o2y[i + 1];
                
                average_hr += w->m_hry[i];
                average_o2 += w->m_o2y[i];
            }
            
            w->m_hry[255] = t.first;
            w->m_o2y[255] = t.second;
            
            average_hr += w->m_hry[255];
            average_o2 += w->m_o2y[255];
            
            average_hr /= 256;
            average_o2 /= 256;
            
            // print heart rate
            oss << R"html(<font size="4">)html" << average_hr << "</font>";
            w->m_heartRate->setText(oss.str().c_str());
            //w->m_hrStr = oss.str();
            oss.clear();
            
            // print o2
            oss << R"html(<font size="4">)html" << average_o2 << "</font>";
            //w->m_oxygenSaturation->setText(oss.str().c_str());
            oss.clear();
        }
    }
}
