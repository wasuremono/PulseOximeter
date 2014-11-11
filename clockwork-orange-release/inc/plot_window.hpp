/**
 * Christopher Di Bella, Kenneth Ng, Zia Nayamuth, Luke Pearson
 *
 * main_window.hpp
 *
 * interface for comp3601 main window
 *
 * 2014, September 30
 */
#ifndef CLOCKWORK_ORANGE_PLOT_WINDOW_HPP11_INCLUDED
#define CLOCKWORK_ORANGE_PLOT_WINDOW_HPP11_INCLUDED

#include <QWidget>
#include <QtGui>
#include <plot.hpp>
#include <form_layout.hpp>

namespace clockwork_orange
{
    class plot_window : public QWidget
    {
        Q_OBJECT
    private:
        QVBoxLayout* m_mainLayout;
        QGroupBox*   m_group;
        QFormLayout* m_formLayout;
        plot        m_hr;
        //form_layout        m_ppg;
    public:
        plot_window(const size_t x, const size_t y, QWidget* parent = nullptr);
        ~plot_window();
        
        void update(const size_t y_bottom, const size_t y_top, const QVector<double>& hry, const QVector<double>& o2y)
        {
            m_hr.update(y_bottom, y_top, hry);
            auto a = o2y;
            a = a;
        }
    };
}

#endif // CLOCKWORK_ORANGE_PLOT_WINDOW_HPP11_INCLUDED
