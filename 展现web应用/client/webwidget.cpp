#include "webwidget.h"

webwidget::webwidget(QWidget *parent) : QWidget(parent)
{
    this->webview=new QWebEngineView();

}

webwidget:: ~webwidget()
{
    delete this->webview;
}

void webwidget::showweb(QString url)
{
    this->webview->setUrl(QUrl(url));
    this->webview->show();
}
