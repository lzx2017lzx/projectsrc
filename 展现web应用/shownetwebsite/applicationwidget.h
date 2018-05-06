#ifndef APPLICATIONWIDGET_H
#define APPLICATIONWIDGET_H

#include <QtWidgets/QWidget>
#include<QLabel>
#include<QDebug>
class ApplicationWidget : public QWidget
{
    Q_OBJECT
public:
    explicit ApplicationWidget(QWidget *parent,QString strGraph,QString text,QString url);
    ~ApplicationWidget();
    QLabel *labelgraph;
    QLabel*labeltext;
    QString url;
    void mousePressEvent(QMouseEvent *ev);
signals:
    void sigClick(QString);
public slots:
    void emitsigClick();
};

#endif // APPLICATIONWIDGET_H
