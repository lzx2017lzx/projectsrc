#ifndef WEBWIDGET_H
#define WEBWIDGET_H

#include <QWidget>
#include<QtWebEngine/QtWebEngine>
#include <QWebEngineView>
#include<QtWebEngineWidgets/QtWebEngineWidgets>
#include<QString>
class webwidget : public QWidget
{
    Q_OBJECT
public:
    explicit webwidget(QWidget *parent = 0);
    ~webwidget();
    QWebEngineView *webview;
    void showweb(QString url);
signals:

public slots:
};

#endif // WEBWIDGET_H
