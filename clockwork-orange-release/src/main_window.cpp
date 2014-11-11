/**
* Christopher Di Bella, Kenneth Ng, Zia Nayamuth, Luke Pearson
*
* main_window.cpp
*
* implementation for comp3601 main window
*
* 2014, September 30
* 
* Audio library supplied by Firelight Technologies' FMOD Sound System
* FMOD Sound System, copyright (c) Firelight Technologies Pty, Ltd., 1994-2014.
* Consult LICENSE.TXT for a copy of the FMOD Sound System license
*/

#include <main_window.hpp>
#include <utility>
#include <device.hpp>
#include <cstdlib>
#include <smart_thread.hpp>
#include <sstream>
#include <ctime>
#include <random>
#include <algorithm>
#include <iomanip>
#include <cassert>
using std::make_pair;

namespace clockwork_orange
{
    bool in_range(const int v, const int lhs, const int rhs)
    {
        return (v > lhs && v <= rhs);
    }

    main_window::main_window(QWidget* parent) : QWidget(parent), 
    m_mainLayout      { new QVBoxLayout(this)                                                },
    m_group           { new QGroupBox                                                        },
    m_formLayout      { new QFormLayout                                                      },
    m_connectionStatus{ new QLabel{ R"html(<font size="4">Not connected</font>)html"        }},
    m_heartRate       { new QLabel{ R"html(<font size="4">0</font>)html"                    }},
    m_oxygenSaturation{ new QLabel{ R"html(<font size="4">0</font>)html"                    }},
    m_heartStatus     { new QLabel{ R"html(<font size="4">No heart rate</font>)html"        }},
    m_oxygenStatus    { new QLabel{ R"html(<font size="4">No oxygen saturation</font>)html" }},
    m_connect         { new QPushButton{ "Connect to device", this                          }},
    m_plotData        { new QPushButton{ "Plot data", this                                  }},
    m_plot{new QCustomPlot}, m_timeDifference(std::chrono::milliseconds(10)), m_minHr(0), m_maxHr(255), m_updateTick(0),
    m_system(nullptr), m_sound(nullptr), m_hrAlarm(nullptr), m_o2Alarm(nullptr)
    {
        m_plot->plotLayout()->clear();
        /*m_plot->setGeometry(1000, 250, 1000, 390); 
        m_plot->addGraph();  
        m_plot->xAxis->setRange(0, 4000);
        m_plot->yAxis->setRange(0, 900);*/

        /////////////////////////////////////////////// Top layout ///////////////////////////////////////////////
        auto* top_layout    = new QCPLayoutGrid;
        m_plot->plotLayout()->addElement(0, 0, top_layout);

        auto* top_left  = new QCPAxisRect(m_plot, false);
        auto* top_right = new QCPAxisRect(m_plot, false);
        top_layout->addElement(0, 0, top_left);
        top_layout->addElement(0, 1, top_right);

        // Size constraints
        top_left->setMinimumSize(532, 404);
        top_left->setMaximumSize(1920/2, 1080/2);

        top_right->setMinimumSize(532, 404);
        top_right->setMaximumSize(1920/2, 1080/2);

        // Axes
        top_left->addAxes(QCPAxis::atBottom | QCPAxis::atLeft | QCPAxis::atTop);
        top_left->axis(QCPAxis::atBottom)->setRange(0, 100);
        top_left->axis(QCPAxis::atLeft)->setRange(0, 105);
        top_left->axis(QCPAxis::atBottom)->grid()->setVisible(true);
        top_left->axis(QCPAxis::atBottom)->setTickLabels(false);
        top_left->axis(QCPAxis::atLeft)->grid()->setVisible(true);
        top_left->axis(QCPAxis::atTop)->setAutoTicks(false);
        top_left->axis(QCPAxis::atTop)->setLabel("Oxygen Saturation");
        top_left->axis(QCPAxis::atLeft)->setLabel("percentage");
        top_left->axis(QCPAxis::atBottom)->setLabel("Time");
        
        top_right->addAxes(QCPAxis::atBottom | QCPAxis::atLeft | QCPAxis::atTop);
        top_right->axis(QCPAxis::atBottom)->setRange(0, 100);
        top_right->axis(QCPAxis::atLeft)->setRange(0, 255);
        top_right->axis(QCPAxis::atBottom)->grid()->setVisible(true);
        top_right->axis(QCPAxis::atBottom)->setTickLabels(false);//setVisible(true);
        top_right->axis(QCPAxis::atLeft)->grid()->setVisible(true);
        top_right->axis(QCPAxis::atTop)->setAutoTicks(false);
        top_right->axis(QCPAxis::atTop)->setLabel("Heart Rate");
        top_right->axis(QCPAxis::atLeft)->setLabel("bpm");
        top_right->axis(QCPAxis::atBottom)->setLabel("Time");
        
        // Graphs
        m_plot->addGraph(top_left->axis(QCPAxis::atBottom), top_left->axis(QCPAxis::atLeft));
        m_plot->addGraph(top_right->axis(QCPAxis::atBottom), top_right->axis(QCPAxis::atLeft));
        ////////////////////////////////////////////// Bottom layout //////////////////////////////////////////////
        //auto* bottom_layout = new QCPLayoutGrid;
        auto* bottom_layout    = new QCPLayoutGrid;
        auto* bottom_rect = new QCPAxisRect(m_plot, false);
        m_plot->plotLayout()->addElement(1, 0, bottom_layout);
        bottom_layout->addElement(0, 0, bottom_rect);

        // Axes
        bottom_rect->addAxes(QCPAxis::atBottom | QCPAxis::atLeft | QCPAxis::atTop);
        bottom_rect->axis(QCPAxis::atBottom)->setRange(0, 1024);
        bottom_rect->axis(QCPAxis::atLeft)->setRange(130, 850);
        bottom_rect->axis(QCPAxis::atTop)->setAutoTicks(false);
        bottom_rect->axis(QCPAxis::atTop)->setLabel("PPG");
        bottom_rect->axis(QCPAxis::atBottom)->setLabel("Time");
        bottom_rect->axis(QCPAxis::atBottom)->grid()->setVisible(true);
        bottom_rect->axis(QCPAxis::atLeft)->grid()->setVisible(true);
        bottom_rect->axis(QCPAxis::atBottom)->setTickLabels(false);
        bottom_rect->axis(QCPAxis::atLeft)->setTickLabels(false);

        // Size constraints
        bottom_rect->setMinimumSize(1044, 404);
        bottom_rect->setMaximumSize(1920, 1080/2);

        // Graph
        m_plot->addGraph(bottom_rect->axis(QCPAxis::atBottom), bottom_rect->axis(QCPAxis::atLeft));
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////

        
        /*     for (int i = 0; i<100; ++i)
    {       
        customPlot.graph(0)->addData(i, i);
        customPlot.replot();
        //Simulate delay   
        //parent->paintEvent();
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        
        }*/
        m_mainLayout->addWidget(m_group);
        m_formLayout->addRow(new QLabel(tr("<h2>Device status:</h2>")),             m_connectionStatus);
        m_formLayout->addRow(new QLabel(tr("<h2>Average heart rate (bpm):</h2>")),  m_heartRate);
        m_formLayout->addRow(new QLabel(tr("<h2>Heart rate status:</h2>")),         m_heartStatus);
        m_formLayout->addRow(new QLabel(tr("<h2>Average oxygen saturation:</h2>")), m_oxygenSaturation);
        m_formLayout->addRow(new QLabel(tr("<h2>Oxygen saturation status:</h2>")),  m_oxygenStatus);
        m_formLayout->addRow(m_connect, m_plotData);
        m_group->setLayout(m_formLayout);
        
        connect(m_connect,     SIGNAL(pressed()),       this, SLOT(establish_connection()));
        connect(m_plotData,    SIGNAL(pressed()),       this, SLOT(show_plot()           ));
        connect(&m_hrAverage,  SIGNAL(value_changed()), this, SLOT(update_bpm()           ));
        connect(&m_ppgAverage, SIGNAL(value_changed()), this, SLOT(update_ppg()          ));
        connect(&m_o2Average,  SIGNAL(value_changed()), this, SLOT(update_o2()           ));
        connect(&m_boardStatus, SIGNAL(value_changed()), this, SLOT(update_board_status()));
        //        connect(&m_ppgAverage, SIGNAL(value_changed()), this, SLOT(update_ppg()          ));
        connect(&m_o2Average,  SIGNAL(value_changed()), this, SLOT(update_o2()           ));
        
        m_hrTimer = std::chrono::high_resolution_clock::now() + m_timeDifference;
        m_o2Timer = std::chrono::high_resolution_clock::now() + m_timeDifference;
        
        FMOD_System_Create(&m_system);
        FMOD_System_Init(m_system, 512, FMOD_INIT_NORMAL, nullptr);
        FMOD_System_CreateSound(m_system, "alarm.wav", FMOD_DEFAULT, nullptr, &m_sound);
        
    }
    void main_window::closeEvent(QCloseEvent*)
    {
        // m_plot->hide();
        m_connected = false;
        exit(1);
    }
    
    main_window::~main_window()
    {
        delete m_plot;
        delete m_plotData;
        delete m_connect;
        delete m_oxygenStatus;
        delete m_heartStatus;
        delete m_oxygenSaturation;
        delete m_heartRate;
        delete m_connectionStatus;
        delete m_formLayout;
        delete m_group;
        delete m_mainLayout;
    }
    
    void main_window::show_plot()
    {
        m_plot->show();
    }
    
    void main_window::establish_connection()
    {
        m_connected = true;
        device::connect(m_boardStatus);
        detachable_thread t1(std::thread(device::interrupt));
        detachable_thread t2(std::thread(&clockwork_orange::main_window::update, this));
    }
    
    void main_window::update()
    {
        std::ostringstream oss;
        
        while (m_connected == true)
        {
            auto t = device::get();
            
            if (std::get<0>(t) < 0)
            {
                if (std::get<0>(t) == -1)
                {
                    m_boardStatus.update(R"html(<font size="4" color="red">Failed to open data</font>)html");
                }
                else if (std::get<0>(t) == -3)
                {
                    m_boardStatus.update(R"html(<font size="4" color="red">An error occurred in the erc</font>)html");
                }
                else if (std::get<0>(t) % 2 == 0) // register error!
                {
                    auto r = std::get<0>(t) / -2;
                    oss << R"html(<font size="4" color="red">Failed to get data from register )html" << r << ".</font>";
                    m_boardStatus.update(oss.str().c_str());
                }
                
                m_connected = false;
            }
            else
            {
                ++m_updateTick;
                
                // print heart rate
                m_ppgAverage.update(std::get<0>(t) << 2);
                m_hrAverage.update(std::get<1>(t));                
                m_o2Average.update(std::get<2>(t));
            }
        }
    }
    
    void main_window::update_board_status()
    {
        m_connectionStatus->setText(m_boardStatus.val());
    }
    
    void main_window::update_ppg()
    {
        static int last = 160;
        //int ppg = last;
        if (m_ppgAverage.val() > 50){
            last = m_ppgAverage.val();
        
            //ppg = m_ppgAverage.val();
        }
        //std::ostringstream oss;
        //oss << std::setprecision(4) << R"html(<font size="4">)html" << ppg << "</font>";
        //m_heartRate->setText(oss.str().c_str());
        
        if (m_updateTick < 1020)
        {
            m_plot->graph(2)->addData(m_updateTick, last);
            /*if (m_ppgAverage.val() > 0)
            {
                m_plot->graph(2)->addData(m_updateTick,m_ppgAverage.val());
                
            } else {
                m_plot->graph(2)->addData(m_updateTick, last);
            }*/
            m_plot->replot();
        }
        else
        {
            m_plot->graph(2)->clearData();
            m_updateTick = 0;
        }
    }
    
    void main_window::update_bpm()
    {
        static int temp = 0;
        static auto saved_hr = make_pair(m_hrAverage.val(), m_hrAverage.val());
        
        saved_hr.first  = saved_hr.second;
        saved_hr.second = m_hrAverage.val();
        
      
        
        if (saved_hr.second <= 65 || saved_hr.second >= 95)
        {
            if (in_range(saved_hr.second, 94, 100) || in_range(saved_hr.second, 59, 65))
            {
                m_heartStatus->setText(R"html(<font size="4" color="orange">HR irregular</font>)html");
                play_sound(m_hrAlarm, 1.0);
            }
            else if (in_range(saved_hr.second, 100, 105) || in_range(saved_hr.second, 54, 60))
            {
                m_heartStatus->setText(R"html(<font size="4" color="red"><b>HR POOR</b></font>)html");
                play_sound(m_hrAlarm, 2.0);
            }
            else
            {
                m_heartStatus->setText(R"html(<font size="4" color="red"><b><i>CRITICAL</i></b></font>)html");
                play_sound(m_hrAlarm, 3.0);
            }
        }
        else
        {
            //FMOD_Channel_Stop(m_channel);
            m_heartStatus->setText(R"html(<font size="4" color="black">GOOD</font>)html");
        }
        
        std::ostringstream oss;
        oss << std::setprecision(4) << R"html(<font size="4">)html" << saved_hr.second << "</font>";
        m_heartRate->setText(oss.str().c_str());
        
        if (m_updateTick % 25 == 0)
        {
            ++temp;
            if (m_updateTick % 10 == 0)
            {
                m_plot->graph(1)->addData(temp, saved_hr.second);
            }
        }
        
        if (temp >= 100)
        {
            m_plot->graph(1)->clearData();
            temp = 0;
        }
    }
    
    void main_window::update_o2()
    {
        static int temp = 0;
        
        static auto saved_o2 = make_pair(m_o2Average.val(), m_o2Average.val());
        
        saved_o2.first  = saved_o2.second;
        saved_o2.second = m_o2Average.val();
        
        if (saved_o2.second <= 96)
        {
            if (in_range(saved_o2.second, 94, 96))
            {
                m_oxygenStatus->setText(R"html(<font size="4" color="orange">Oxygen saturation low</font>)html");
                play_sound(m_o2Alarm, 1.0);
            }
            else if (in_range(saved_o2.second, 90, 94))
            {
                m_oxygenStatus->setText(R"html(<font size="4" color="red"><b>Oxygen saturation POOR</b></font>)html");
                play_sound(m_o2Alarm, 2.0);
            }
            else
            {
                m_oxygenStatus->setText(R"html(<font size="4" color="red"><b><i>CRITICAL</i></b></font>)html");
                play_sound(m_o2Alarm, 3.0);
            }
        }
        else
        {
            //FMOD_Channel_Stop(m_channel);
            m_oxygenStatus->setText(R"html(<font size="4" color="black">GOOD</font>)html");
        }
        
        std::ostringstream oss;
        oss << std::setprecision(4) << R"html(<font size="4">)html" << saved_o2.second << "</font>";
        m_oxygenSaturation->setText(oss.str().c_str());
        
        if (m_updateTick % 25 == 0)
        {
            ++temp;
            if (m_updateTick % 10== 0)
            {
                m_plot->graph(0)->addData(temp, saved_o2.second);
            }
        }
        if (temp >= 100)
        {
            m_plot->graph(0)->clearData();
            temp = 0;
        }
    }
    
    void main_window::play_sound(FMOD_CHANNEL* channel, const float pitch)
    {
        FMOD_BOOL is_playing;
        FMOD_Channel_IsPlaying(channel, &is_playing);
        if (channel == nullptr || is_playing == 0)
        {
            FMOD_System_PlaySound(m_system, m_sound, nullptr, false, &channel);
            //FMOD_Channel_SetLoopCount(m_channel, -1);
            //FMOD_Channel_Pause(m_channel, false);
        }
        
        FMOD_Channel_SetPitch(channel, pitch);
        FMOD_System_Update(m_system);
    }
}
// ppg 0 bpm 1 oxsat 2
