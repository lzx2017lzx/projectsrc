

#启动fastDFS
sudo fdfs_trackerd ./conf/tracker.conf restart
sudo fdfs_storaged ./conf/storage.conf restart

#启动redis
redis-server ./conf/redis.conf

#启动nginx
#杀死apache
sudo /usr/local/nginx/sbin/nginx 


#杀死已经启动的cgi
 kill -9 `ps aux|grep "demo_cgi" |grep  -v grep |awk '{print $2}'` 
 kill -9 `ps aux|grep "echo_cgi" |grep  -v grep |awk '{print $2}'` 
 kill -9 `ps aux|grep "upload_cgi" |grep  -v grep |awk '{print $2}'` 
 kill -9 `ps aux|grep "data_cgi" |grep  -v grep |awk '{print $2}'` 
 kill -9 `ps aux|grep "login_cgi" |grep  -v grep |awk '{print $2}'` 
 kill -9 `ps aux|grep "reg_cgi" |grep  -v grep |awk '{print $2}'` 

#启动cgi
spawn-fcgi -a 127.0.0.1 -p 8082 -f ./demo_cgi
spawn-fcgi -a 127.0.0.1 -p 8083 -f ./echo_cgi
spawn-fcgi -a 127.0.0.1 -p 8084 -f ./upload_cgi
spawn-fcgi -a 127.0.0.1 -p 8085 -f ./data_cgi
spawn-fcgi -a 127.0.0.1 -p 8086 -f ./reg_cgi
spawn-fcgi -a 127.0.0.1 -p 8087 -f ./login_cgi
