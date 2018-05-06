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

    //对控件进行布局
    // QHBoxLayout*hBoxLayout=new QHBoxLayout(this);
    mainLayout=new QGridLayout(this);//设置对象，划分空间
    centerLayout=new QGridLayout;
    mainLayout->setRowStretch(0,1);
    mainLayout->setRowStretch(2,1);
    mainLayout->setColumnStretch(0,1);
    mainLayout->setColumnStretch(2,1);
    mainLayout->addLayout(centerLayout,1,1);//如果不先在centerlayout工作区间的四周添加弹簧，就不能保证显示的窗口在中间

    centerLayout->setRowStretch(4,1);//在新的centerlayout中划分区间
    centerLayout->setColumnStretch(3,1);

    //添加构件
    centerLayout->addWidget(label1,0,0,1,1);
    centerLayout->addWidget(edit1,0,1,1,2);

    centerLayout->addWidget(label2,1,0,1,1);
    centerLayout->addWidget(edit2,1,1,1,2);

    //用QHBoxLayout对象再次对button1和buttong2进行管理，并放入弹簧
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
