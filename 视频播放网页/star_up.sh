pid=`ps aux|grep "whentimeisupchangename" |grep  -v grep |awk '{print $2}'`
if [ $pid!=0 ];then
    kill -9 $pid
fi


nohup /root/cpp/changehtmldirname/whentimeisupchangename >/dev/null 2>&1 &
