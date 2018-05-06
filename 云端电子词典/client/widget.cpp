#include "widget.h"

Widget::Widget(QWidget *parent)
    : QWidget(parent)
{
    this->setBaseSize(QSize(600,600));
    sct=new socketclient();
    edit1=new QLineEdit;
    edit1->setPlaceholderText("words searched");
    edit1->setFixedHeight(20);
    edit1->setFixedWidth(110);

    edit2=new QLineEdit;
    edit2->setPlaceholderText("meaning translated");
    edit2->setFixedHeight(40);
    edit2->setFixedWidth(110);

    button1=new QPushButton("search");
    button2=new QPushButton("exit");

    label1=new QLabel("words");
    label2=new QLabel("meaning");

    mainLayout=new QGridLayout(this);
    centerLayout=new QGridLayout;

    mainLayout->setRowStretch(0,1);
    mainLayout->setRowStretch(2,1);
    mainLayout->setColumnStretch(0,1);
    mainLayout->setColumnStretch(2,1);
    mainLayout->addLayout(centerLayout,1,1);

    centerLayout->setRowStretch(4,1);
    centerLayout->setColumnStretch(3,1);


    centerLayout->addWidget(label1,0,0,1,1);
    centerLayout->addWidget(edit1,0,1,1,2);

    centerLayout->addWidget(label2,1,0,1,1);
    centerLayout->addWidget(edit2,1,1,1,2);


    hbox=new QHBoxLayout;
    hbox->addWidget(button1);
    hbox->addStretch(1);
    hbox->addWidget(button2);
    centerLayout->addLayout(hbox,3,0,1,3);


    connect(button1, SIGNAL(clicked()),
            this, SLOT(searchwords()));
    connect(button2, SIGNAL(clicked()),
            this, SLOT(close()));


}

Widget::~Widget()
{
    delete edit1;
    delete edit2;
    delete label1;
    delete label2;
    delete button1;
    delete button2;
    delete mainLayout;
    delete centerLayout;
    delete hbox;
    delete sct;

}

void Widget::searchwords()
{
    QString text=edit1->text();
    qDebug()<<"text:"<<text;
    edit2->setText("");
    std::string strtext;
    strtext=text.toStdString();
    if(!strtext.empty())
    {
        strtext.erase(0,strtext.find_first_not_of(" "));
        strtext.erase(strtext.find_last_not_of(" ") + 1);
    }
    text=QString::fromStdString(strtext);

    char*recData=NULL;
    int ret=0;

    QJsonObject resp;
    resp.insert("indexcmd",QJsonValue(1));
    resp.insert("key", text);


    QByteArray buf = QJsonDocument(resp).toJson();
    printf("before socketfunc buf:%s-----\n",(char*)buf.data());
    socketfunc((char*)buf.data(),&recData,ret);

    if(ret>0)
    {
        printf("recData:%s\n",recData);
        QJsonDocument doc = QJsonDocument::fromJson(QByteArray(recData));
        const QJsonObject &obj=doc.object();
        short int ret = obj.value("return").toInt();

        if(ret==0)
        {
            qDebug()<<"search success";
            const QJsonObject &desobj=obj.value("descrip").toObject();
            int count=desobj.count();
            qDebug()<<"count:"<<count;
            for(int i=0;i<count;i++)
            {
                const QJsonObject &rowobj=desobj.value(QString::number(i,10)).toObject();
                QString &id=rowobj.value("id").toString();
                QString &chinesekey=rowobj.value("chinesekey").toString();
                QString &englishvalue=rowobj.value("englishvalue").toString();
                qDebug()<<"id:"<<id<<",chinesekey:"<<chinesekey<<",englishvalue:"<<englishvalue<<endl;
                if(englishvalue.size()!=0)
                    edit2->setText(englishvalue);
                else
                    edit2->setText(QString("have no data"));
            }

        }else if(ret==-3)
        {
            qDebug()<<"password error";
        }else if(ret==-10)
        {
            qDebug()<<"server error";
        }else if(ret==-1000)
        {
            qDebug()<<"unknow error";
        }
        free(recData);
        recData=NULL;
    }
    free(recData);
}

void Widget::socketfunc(char *buf,char **recData,int &ret)
{
    printf("sendbuf:%s-----\n",buf);
    int writeret=sct->writedata.WriteBuf(sct->sclient,buf);
    if(writeret<0)
    {
        ret=writeret;
        qDebug()<<"errno:"<<errno;
        sct->continueConnection();
        return;
    }

    *recData = sct->writedata.ReadBuf(sct->sclient,&ret);
    if(ret>0){
        recData[ret] = 0x00;
        cout<<"ret:"<<ret<<endl;
        printf("recData:%s\n",*recData);
    }else
    {
        sct->continueConnection();
        qDebug()<<"errno:"<<errno;
        return;
    }
}
