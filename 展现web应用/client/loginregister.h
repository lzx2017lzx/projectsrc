#ifndef LOGINREGISTER_H
#define LOGINREGISTER_H

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
class loginregister : public QWidget
{
    Q_OBJECT
public:
    explicit loginregister(QWidget *parent = 0);

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
signals:

public slots:
    void shownet();
};

#endif // LOGINREGISTER_H
