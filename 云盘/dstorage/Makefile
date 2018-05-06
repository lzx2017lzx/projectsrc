
CC=gcc
CPPFLAGS= -I./include  -I/usr/include/fastdfs/ -I/usr/include/fastcommon/ -I/usr/local/include/hiredis/ -I/usr/include/mysql/
CFLAGS=-Wall 
LIBS= -lfdfsclient -lfastcommon -lhiredis -lfcgi -lm -lmysqlclient

main=./test_main
test_hiredis = ./test/test_hiredis
json_test=./test/json_test
test_redis_op = ./test/test_redis_op
save_one_file = ./test/save_one_file
select_files = ./test/select_files
demo_cgi =./demo_cgi
echo_cgi =./echo_cgi
upload_cgi =./upload_cgi
data_cgi =./data_cgi
login_cgi =./login_cgi
reg_cgi =./reg_cgi




target=$(main)  $(test_hiredis) $(test_redis_op) $(save_one_file) $(select_files) $(json_test)\
       $(demo_cgi) $(echo_cgi) $(upload_cgi) $(data_cgi) $(login_cgi) $(reg_cgi)


ALL:$(target)


#生成所有的.o文件
%.o:%.c
	$(CC) -c $< -o $@ $(CPPFLAGS) $(CFLAGS) 

#login_cgi程序
$(login_cgi):login_cgi.o   make_log.o dao_mysql.o cJSON.o util.o
	$(CC) $^ -o $@ $(LIBS)

#reg_cgi程序
$(reg_cgi):reg_cgi.o   make_log.o dao_mysql.o cJSON.o util.o
	$(CC) $^ -o $@ $(LIBS)

#data_cgi程序
$(data_cgi):data_cgi.o   make_log.o util.o cJSON.o upload_file.o redis_op.o fdfs_api.o
	$(CC) $^ -o $@ $(LIBS)

#upload_cgi程序
$(upload_cgi):upload_cgi.o   make_log.o util.o upload_file.o redis_op.o fdfs_api.o cJSON.o
	$(CC) $^ -o $@ $(LIBS)

#echo_cgi程序
$(echo_cgi):echo_cgi.o  
	$(CC) $^ -o $@ $(LIBS)

#demo_cgi程序
$(demo_cgi):demo_cgi.o  
	$(CC) $^ -o $@ $(LIBS)


#select_files程序
$(select_files):./test/select_files.o  redis_op.o  make_log.o
	$(CC) $^ -o $@ $(LIBS)

#save_one_file程序
$(save_one_file):./test/save_one_file.o  redis_op.o fdfs_api.o make_log.o
	$(CC) $^ -o $@ $(LIBS)

#test_redis_op程序
$(test_redis_op):./test/test_redis_op.o make_log.o redis_op.o
	$(CC) $^ -o $@ $(LIBS)

#test_hiredis程序
$(test_hiredis):./test/test_hiredis_api.o 
	$(CC) $^ -o $@ $(LIBS)

#json_test程序
$(json_test):./test/cJSON_test.o cJSON.o
	$(CC) $^ -o $@ $(LIBS)

#test_main程序
$(main):./main.o ./fdfs_api.o ./make_log.o
	$(CC) $^ -o $@ $(LIBS)


#clean指令

clean:
	-rm -rf ./*.o $(target) ./test/*.o

distclean:
	-rm -rf ./*.o $(target) ./test/*.o

#将clean目标 改成一个虚拟符号
.PHONY: clean ALL distclean
