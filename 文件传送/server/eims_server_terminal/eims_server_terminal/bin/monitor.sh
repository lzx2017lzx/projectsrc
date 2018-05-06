#!/bin/sh
curpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while [ 1 ]
do
ps -ef | grep eims_server_terminal| grep -v grep
test $? -eq 0 || $curpath/eims_server_terminal &
sleep 10
done
