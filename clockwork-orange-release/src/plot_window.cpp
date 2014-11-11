#include <plot_window.hpp>

namespace clockwork_orange
{
    plot_window::plot_window(const size_t x, const size_t y, QWidget* parent) : QWidget(parent), m_mainLayout { new QVBoxLayout(this)                                 },
                                                                                m_group      { new QGroupBox                                         },
                                                                                m_formLayout { new QFormLayout                                       },
                                                                                m_hr{ 15, QPen(Qt::red), this, parent }//, m_o2{ 15, QPen(Qt::blue), this, parent }
                                                                                //m_hr         { new plot{ 15, QPen(Qt::red),  this, parent }},
                                                                                //m_o2         { new plot{ 15, QPen(Qt::blue), this, parent }}
                                                                               // m_ppg        { new plot{ 15, QPen(Qt::yellow), this, parent }}
    {
        m_hr.resize(800, 600);
//        m_o2.resize(512, 384);
       // m_ppg->resize(1024, 384);
        int a = x + y;
        a = a;
        //m_formLayout->addRow(&m_hr, &m_o2);
       // QPoint o2p(512, 384);
       // m_o2->move(o2p.x(), o2p.y());
        //m_formLayout.m_formLayout->addRow(m_hr, m_o2);
//        m_formLayout->addRow(m_ppg);
    }
    
    plot_window::~plot_window()
    {
        //delete m_ppg;
        //delete m_o2;
        //delete m_hr;
        delete m_formLayout;
        delete m_group;
        delete m_mainLayout;
    }
}
