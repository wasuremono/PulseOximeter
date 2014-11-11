/**
 * Christopher Di Bella, Kenneth Ng, Zia Nayamuth, Luke Pearson
 *
 * smart_thread.hpp
 *
 * implementation for comp3601 plotter
 *
 * 2014, September 30
 */
 
#include <plot.hpp>
#include <iostream>
namespace clockwork_orange
{
    plot::plot(const size_t x_axis_size, const QPen& colour, QWidget* x, QWidget* parent) : QWidget(parent), m_plot(new QCustomPlot(x)), m_xAxis(x_axis_size)
    {
        m_plot->setLocale(QLocale(QLocale::English, QLocale::UnitedKingdom));

        for (size_t i = 0; i < x_axis_size; ++i)
        {
            m_xAxis[i] = i;
        }
        
        
        m_plot->addGraph();
        m_plot->graph(0)->setName("Beats per minute");
        m_plot->graph(0)->setPen(colour);
        
        m_plot->addGraph();
        m_plot->graph(1)->setName("Oxygen saturation percentage");

        m_plot->addGraph();
        m_plot->graph(2)->setName("PPG");
        
//        auto* rect = new QCPAxisRect(m_plot);
//        auto* axis1 = m_plot->axisRect(0)->addAxis(QCPAxis::atLeft);
//        auto* axis2 = m_plot->axisRect(0)->addAxis(QCPAxis::atBottom);
        auto* r = new QCPAxisRect(m_plot);
        m_plot->plotLayout()->addElement(0, 1, r);
        m_plot->plotLayout()->addElement(1, 0, r);
        m_plot->plotLayout()->setColumnStretchFactor(1, 2.0);
        m_plot->axisRect(1)->axis(QCPAxis::atLeft, 1);
//        axis1->setRange(100, 200);
//        axis2->setRange(200, 300);
        
        m_plot->xAxis->setRange(0, x_axis_size);
        m_plot->yAxis->setRange(0, 1024);
    }
    
    plot::~plot()
    {
        delete m_plot;
    }
    
    void plot::update(const size_t y_bottom, const size_t y_top, const QVector<double>& y_axis)
    {
        m_plot->yAxis->setRange(y_bottom, y_top);
        m_plot->graph(0)->setData(m_xAxis, y_axis);
        m_plot->replot();
    }
    
    void plot::show()
    {
        m_plot->show();
    }
    
    void plot::hide()
    {
        m_plot->hide();
    }
    
    void plot::resize(const size_t width, const size_t height)
    {
        m_plot->resize(width, height);
    }
}
