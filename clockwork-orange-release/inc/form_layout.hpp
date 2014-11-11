#ifndef FORM
#define FORM

#include <QWidget>
#include <QtGui>
#include <plot.hpp>

namespace clockwork_orange
{
    class form_layout : public QWidget
    {
        Q_OBJECT
    public:
        plot* m_plot;
        
        form_layout(const size_t x_axis_size, const QPen& colour, QWidget* parent) : QWidget(parent), m_plot{ new plot{ x_axis_size, colour, this, parent }} { }
        ~form_layout() { delete m_plot; }
    };
}

#endif // FORM
