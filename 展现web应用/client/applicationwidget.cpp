#include "applicationwidget.h"

ApplicationWidget::ApplicationWidget(QWidget *parent,QString strGraph,QString text,QString url) : QWidget(parent),url(url)
{
    this->setFixedHeight(100);
    this->setFixedWidth(80);
    labelgraph=new QLabel(this);
    labeltext=new QLabel(this);
    labelgraph->setGeometry(0,0,80,80);
    labeltext->setGeometry(0,80,80,20);
    labeltext->setText(text);
    labeltext->setTextFormat(Qt::AutoText);
    labeltext->setAlignment(Qt::AlignCenter);

    QPalette palette;
    QPixmap pixmap;
    //    pixmap.load(":/new/prefix1/8.jpg");
    QString str(strGraph);
    //  QByteArray bytearray("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsAQAAAABRBrPYAAABG0lEQVR42u3aPRKDIBCG4bXyGB5VjsoRUlpJhF2QyZ8pBCeZ1yJj8LH6JruLRsI3x01gMBgMBvsptogdk54NwdnCAOvH9Ftwkc0+sqm+AOvEnOjFdUtotBu27GAXMQsLdh1L6wvsIpYLl9Wso/oGa8D2Jm6JHfV62PlsP9IN4+HcC2vAUpGK/XsqsaWc/HOmsGasFKm8bnVMYB2ZhlWahp5tQ9WL9gFrxjQYietlgFoE1pmtVbnKo1QM66HLwJqyuno5GVf7Bb0fpWDns32g1S226IfAurJ6cxe8hmWPPGAdmSs1K/gcHew6lucpq16w/qyMtmmf/TYsWBtWP/Qr2zw/Blg/Vr8YnatG8uH9Kexsxt8hYDAYDPY37A4TakBydL2KgAAAAABJRU5ErkJggg==");
    QByteArray bytearray=str.toLocal8Bit();
    QByteArray Ret_bytearray;
    Ret_bytearray=QByteArray::fromBase64(bytearray);

    //   QBuffer buffer(&Ret_bytearray);
    pixmap.loadFromData(Ret_bytearray);
    labelgraph->setAutoFillBackground(true);
    //  palette.setBrush(QPalette::Window,QBrush(pixmap.scaled(this->size(),Qt::IgnoreAspectRatio,Qt::SmoothTransformation)));
    palette.setBrush(QPalette::Background,QBrush(pixmap.scaled(labelgraph->size(),Qt::IgnoreAspectRatio,Qt::SmoothTransformation)));
    labelgraph->setPalette(palette);

   // connect(labeltext, SIGNAL(clicked()),
   //         this, SLOT(emitsigClick()));
}

ApplicationWidget::~ ApplicationWidget()
{
    delete labelgraph;
    delete labeltext;
}

void ApplicationWidget::emitsigClick()
{
    emit sigClick(this->url);
}

void ApplicationWidget::mousePressEvent(QMouseEvent *ev)
{
    emit sigClick(this->url);
    qDebug()<<"sigClick";
}
