#include "loginregister.h"

loginregister::loginregister(QWidget *parent) : QWidget(parent)
{
    edit1=new QLineEdit;
    edit1->setPlaceholderText("username");

    edit2=new QLineEdit;
    edit2->setPlaceholderText("password");

    button1=new QPushButton("login");
    button2=new QPushButton("register");

    label1=new QLabel("username");
    label2=new QLabel("password");

    //�Կؼ����в���
    // QHBoxLayout*hBoxLayout=new QHBoxLayout(this);
    mainLayout=new QGridLayout(this);//���ö��󣬻��ֿռ�
    centerLayout=new QGridLayout;
    mainLayout->setRowStretch(0,1);
    mainLayout->setRowStretch(2,1);
    mainLayout->setColumnStretch(0,1);
    mainLayout->setColumnStretch(2,1);
    mainLayout->addLayout(centerLayout,1,1);//���������centerlayout���������������ӵ��ɣ��Ͳ��ܱ�֤��ʾ�Ĵ������м�

    centerLayout->setRowStretch(4,1);//���µ�centerlayout�л�������
    centerLayout->setColumnStretch(3,1);

    //��ӹ���
    centerLayout->addWidget(label1,0,0,1,1);
    centerLayout->addWidget(edit1,0,1,1,2);

    centerLayout->addWidget(label2,1,0,1,1);
    centerLayout->addWidget(edit2,1,1,1,2);

    //��QHBoxLayout�����ٴζ�button1��buttong2���й��������뵯��
    hbox=new QHBoxLayout;
    hbox->addWidget(button1);
    hbox->addStretch(1);
    hbox->addWidget(button2);
    centerLayout->addLayout(hbox,3,0,1,3);

}

void loginregister::shownet()
{
    this->close();
    delete edit1;
    delete edit2;
    delete edit3;
    delete label1;
    delete label2;
    delete button1;
    delete button2;
    delete mainLayout;
    delete centerLayout;
    delete hbox;
}
