/**
 * Christopher Di Bella, Kenneth Ng, Zia Nayamuth, Luke Pearson
 *
 * smart_thread.hpp
 *
 * implementation for comp3601 qthread class
 *
 * 2014, September 30
 */

#ifndef CLOCKWORK_ORANGE_QTHREAD_HPP11_INCLUDED
#define CLOCKWORK_ORANGE_QTHREAD_HPP11_INCLUDED

#include <QObject>
#include <QString>

namespace clockwork_orange
{
    class value_int : public QObject
    {
        Q_OBJECT
    private:
        int m_value;
    public:
        void update(const int& v) { m_value = v; emit value_changed(); }
        int val() const { return m_value; }
    signals:
        void value_changed();
    };
    
    class value_string : public QObject
    {
        Q_OBJECT
    private:
        QString m_value;
    public:
        void update(const QString& v) { m_value = v; emit value_changed(); }
        const QString& val() const { return m_value; }
    signals:
        void value_changed();
    };
}

#endif // CLOCKWORK_ORANGE_QTHREAD_HPP11_INCLUDED
