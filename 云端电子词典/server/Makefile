
CC=g++
CPPFLAGS= -L/usr/lib/mysql
CFLAGS=-Wall -g -std=c++11 -Wno-parentheses -Wno-unused-variable 
LIBS=-lboost_system -lboost_thread -lpthread -lmysqlclient

main=./serverasio

target=$(main)

ALL:$(target)


#生成所有的.o文件
%.o:%.cpp
	$(CC) -c $< -o $@ $(CPPFLAGS) $(CFLAGS) 

#target程序
$(target):common.o configure_file.o consts.o convert.o log.o json.o mysqllib.o handlemessage.o server_manager.o tcp_server.o tcp_session.o tcp_session_pool.o main.o
	$(CC) $^ -o $@ $(LIBS)


clean:
	-rm -rf ./*.o $(target) 

distclean:
	-rm -rf ./*.o $(target) 

#将clean目标 改成一个虚拟符号
.PHONY: clean ALL distclean
