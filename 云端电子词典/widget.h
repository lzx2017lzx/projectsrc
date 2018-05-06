#ifndef WIDGET_H
#define WIDGET_H

#include <QtWidgets/QWidget>
#include<QHBoxLayout>
#include<QLineEdit>
#include<QPushButton>
#include<QGridLayout>
#include<QLabel>
#include<QString>
#include<QList>
#include<QDebug>
#include<QFile>
#include<QVector>
#include<QDataStream>
#include<string>
#include<vector>
#include<QJsonDocument>
#include<QJsonObject>
#include"socketclient.h"
using namespace std;
class Widget : public QWidget
{
    Q_OBJECT

public:
    Widget(QWidget *parent = 0);
    ~Widget();
    socketclient *sct;
    QLineEdit *edit1;
    QLineEdit *edit2;
    QLineEdit *edit3;
    QLabel *label1;
    QLabel *label2;
    QPushButton *button1;
    QPushButton *button2;
    QGridLayout *mainLayout;
    QGridLayout *centerLayout;
    QHBoxLayout *hbox;
    void socketfunc(char *buf,char **recData,int &ret);


signals:

public slots:
    void searchwords();
};

#endif // WIDGET_H
