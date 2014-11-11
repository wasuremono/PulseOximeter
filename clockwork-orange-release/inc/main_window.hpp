/**
 * Christopher Di Bella, Kenneth Ng, Zia Nayamuth, Luke Pearson
 *
 * main_window.hpp
 *
 * interface for comp3601 main window
 *
 * 2014, September 30
 */
#ifndef CLOCKWORK_ORANGE_MAIN_WINDOW_HPP11_INCLUDED
#define CLOCKWORK_ORANGE_MAIN_WINDOW_HPP11_INCLUDED

#include <QWidget>
#include <QtGui>
#include <plot_window.hpp>
#include <value.hpp>
#include <sstream>
#include <chrono>
#include <ratio>
#include <fmod/fmod.h>

namespace clockwork_orange
{
    class main_window : public QWidget
    {
        Q_OBJECT
    private:
        typedef QLabel*      label;
        typedef QPushButton* push_button;
        
        QVBoxLayout* m_mainLayout;
        QGroupBox*   m_group;
        QFormLayout* m_formLayout;
        label        m_connectionStatus, m_heartRate, m_oxygenSaturation, m_heartStatus, m_oxygenStatus;
        push_button  m_connect, m_plotData;
        QCustomPlot* m_plot;
        
        value_int m_hrAverage;
        value_int m_ppgAverage;
        value_int m_o2Average;
        value_string m_boardStatus;
        time_t anchor;
        main_window(const main_window&)            = delete;
        main_window(main_window&&)                 = delete;
        main_window& operator=(const main_window&) = delete;
        main_window& operator=(main_window&&)      = delete;
        
        std::chrono::system_clock::time_point m_hrTimer, m_o2Timer;
        std::chrono::duration<int, std::ratio<1, 1000>> m_timeDifference;
        bool m_connected;
        int m_minHr, m_maxHr, m_updateTick;
        
        FMOD_SYSTEM* m_system;
        FMOD_SOUND*   m_sound;
        FMOD_CHANNEL* m_hrAlarm;
        FMOD_CHANNEL* m_o2Alarm;
        
        void play_sound(FMOD_CHANNEL* channel, const float pitch = 1.0);
    private slots:
        void show_plot();
        void establish_connection();
        void update_ppg();
        void update_o2();
        void update_bpm();
        void update_board_status();
    protected:
        void closeEvent(QCloseEvent* e);
    public:
        main_window(QWidget* parent = nullptr);
        ~main_window();
        
        void update();
    };
    
    //void update(main_window* w);
}

#endif // CLOCKWORK_ORANGE_MAIN_WINDOW_HPP11_INCLUDED
