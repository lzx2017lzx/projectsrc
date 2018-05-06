#ifndef NETWIDGET_H
#define NETWIDGET_H

#include <QtWidgets/QWidget>
#include<QIcon>
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
#include<QBuffer>
#include<QPixmap>
#include<QLabel>
class netwidget : public QWidget
{
    Q_OBJECT
public:
    explicit netwidget(QWidget *parent = 0);
    QLineEdit *edit1;
    QLineEdit *edit2;
    QLineEdit *edit3;
    QLabel*label1;
    QLabel*label2;
    QByteArray Image_To_Base64(QString ImgPath);
    QPixmap Base64_To_Image(QByteArray bytearray,QString SavePath);
signals:

public slots:
};

#endif // NETWIDGET_H
