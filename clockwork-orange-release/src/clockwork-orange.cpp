/**
 * Christopher Di Bella, Kenneth Ng, Zia Nayamuth, Luke Pearson
 *
 * clockwork-orange.cpp
 *
 * entry point for comp3601 program
 *
 * 2014, September 30
 */
 
#include <QApplication>
#include <main_window.hpp>

int main(int argc, char* argv[])
{
    QApplication app(argc, argv);
    
    auto* w = new clockwork_orange::main_window;
    w->show();
    
    return app.exec();
}
