#!/bin/sh

echo "########### start building ... ############"

	g++ main.cpp frame/io/udp/*.cpp frame/io/tcp/*.cpp frame/io/http/*.cpp frame/common/*.cpp frame/db/*.cpp frame/debug/*.cpp frame/lua/*.cpp frame/xml/*.cpp frame/security/*.cpp frame/security/shove/*.cpp frame/security/shove/security/*.cpp frame/security/shove/jwsmtp/*.cpp frame/servermanager/*.cpp eims/protocols/*.cpp other/swig/*.cxx -o bin/eims_server_terminal -Ipublic/depends/boost/include -Ipublic/depends/mysql/include -Ipublic/depends/lua -Lpublic/depends/boost/lib -Lpublic/depends/mysql/lib -Lpublic/depends/lua -lboost_thread -lboost_system -lmysqlclient_r -lshove -llua

echo "########### build finished .   ############"
