/**
 * Christopher Di Bella, Kenneth Ng, Zia Nayamuth, Luke Pearson
 *
 * smart_thread.hpp
 *
 * interface for comp3601 plotter
 *
 * 2014, September 30
 */

#ifndef CLOCKWORK_ORANGE_PLOT_HPP11_INCLUDED
#define CLOCKWORK_ORANGE_PLOT_HPP11_INCLUDED

#include <qcustomplot.h>

namespace clockwork_orange
{
    class plot : public QWidget
    {
    private:
        QCustomPlot* m_plot;
        
        QVector<double> m_xAxis;
        
        enum output { heart_rate, oxygen_saturation };
    public:
        plot(const size_t x_axis_size, const QPen& colour, QWidget* x, QWidget* parent);
        virtual ~plot();
        
        void update(const size_t y_bottom, const size_t y_top, const QVector<double>& y_axis);
        void show();
        void hide();
        void resize(const size_t width, const size_t height);
    };
}

#endif // CLOCKWORK_ORANGE_PLOT_HPP11_INCLUDED
