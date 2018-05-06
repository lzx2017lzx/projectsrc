#include "netwidget.h"

netwidget::netwidget(QWidget *parent) : QWidget(parent)
{
    this->setWindowTitle(QString("helloworld"));
    this->setFixedHeight(800);
    this->setFixedWidth(800);
    //    this->setWindowIcon(QIcon(":/new/prefix1/background.jpg"));

#if 0
    QByteArray src = Image_To_Base64(":/new/prefix1/8.jpg");
    printf("src:%s\n",src.data());
    qDebug()<<"src:"<<src;
    QString;
    QPixmap dest = Base64_To_Image(src,"D:/result.png");
    QPalette palette;
    this->setAutoFillBackground(true);
    palette.setBrush(QPalette::Window,QBrush(dest.scaled(this->size(),Qt::IgnoreAspectRatio,Qt::SmoothTransformation)));
    this->setPalette(palette);
#endif
#if 1
    label1=new QLabel(this);
    label2=new QLabel(this);
    label1->setGeometry(0,0,300,300);
    label1->setFixedHeight(300);
    label1->setFixedWidth(300);
    label2->setGeometry(400,0,300,300);
    label2->setFixedHeight(300);
    label2->setFixedWidth(300);
    QPalette palette;
    QPixmap pixmap;
    //    pixmap.load(":/new/prefix1/8.jpg");
    QString str("iVBORw0KGgoAAAANSUhEUgAAASwAAAEsAQAAAABRBrPYAAABG0lEQVR42u3aPRKDIBCG4bXyGB5VjsoRUlpJhF2QyZ8pBCeZ1yJj8LH6JruLRsI3x01gMBgMBvsptogdk54NwdnCAOvH9Ftwkc0+sqm+AOvEnOjFdUtotBu27GAXMQsLdh1L6wvsIpYLl9Wso/oGa8D2Jm6JHfV62PlsP9IN4+HcC2vAUpGK/XsqsaWc/HOmsGasFKm8bnVMYB2ZhlWahp5tQ9WL9gFrxjQYietlgFoE1pmtVbnKo1QM66HLwJqyuno5GVf7Bb0fpWDns32g1S226IfAurJ6cxe8hmWPPGAdmSs1K/gcHew6lucpq16w/qyMtmmf/TYsWBtWP/Qr2zw/Blg/Vr8YnatG8uH9Kexsxt8hYDAYDPY37A4TakBydL2KgAAAAABJRU5ErkJggg==");
    //  QByteArray bytearray("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsAQAAAABRBrPYAAABG0lEQVR42u3aPRKDIBCG4bXyGB5VjsoRUlpJhF2QyZ8pBCeZ1yJj8LH6JruLRsI3x01gMBgMBvsptogdk54NwdnCAOvH9Ftwkc0+sqm+AOvEnOjFdUtotBu27GAXMQsLdh1L6wvsIpYLl9Wso/oGa8D2Jm6JHfV62PlsP9IN4+HcC2vAUpGK/XsqsaWc/HOmsGasFKm8bnVMYB2ZhlWahp5tQ9WL9gFrxjQYietlgFoE1pmtVbnKo1QM66HLwJqyuno5GVf7Bb0fpWDns32g1S226IfAurJ6cxe8hmWPPGAdmSs1K/gcHew6lucpq16w/qyMtmmf/TYsWBtWP/Qr2zw/Blg/Vr8YnatG8uH9Kexsxt8hYDAYDPY37A4TakBydL2KgAAAAABJRU5ErkJggg==");
    QByteArray bytearray=str.toLocal8Bit();
    QByteArray Ret_bytearray;
    Ret_bytearray=QByteArray::fromBase64(bytearray);

    //   QBuffer buffer(&Ret_bytearray);
    pixmap.loadFromData(Ret_bytearray);
    label1->setAutoFillBackground(true);
    label2->setAutoFillBackground(true);
  //  palette.setBrush(QPalette::Window,QBrush(pixmap.scaled(this->size(),Qt::IgnoreAspectRatio,Qt::SmoothTransformation)));
    palette.setBrush(QPalette::Background,QBrush(pixmap.scaled(label1->size(),Qt::IgnoreAspectRatio,Qt::SmoothTransformation)));
    palette.setBrush(QPalette::Background,QBrush(pixmap.scaled(label2->size(),Qt::IgnoreAspectRatio,Qt::SmoothTransformation)));

    label1->setPalette(palette);
    label2->setPalette(palette);

#endif
}

QByteArray netwidget::Image_To_Base64(QString ImgPath)
{
    QImage image(ImgPath);
    QByteArray ba;
    QBuffer buf(&ba);
    image.save(&buf,"PNG",20);
    QByteArray hexed = ba.toBase64();
    buf.close();
    return hexed;
}

QPixmap netwidget::Base64_To_Image(QByteArray bytearray,QString SavePath)
{
    QByteArray Ret_bytearray;
    Ret_bytearray = QByteArray::fromBase64(bytearray);
    QBuffer buffer(&Ret_bytearray);
    buffer.open(QIODevice::WriteOnly);
    QPixmap imageresult;
    imageresult.loadFromData(Ret_bytearray);
    if(SavePath != "")
    {
        qDebug() <<"save" ;
        imageresult.save(SavePath);
    }
    return imageresult;
}

