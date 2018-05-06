#!/bin/bash

#ps -ef | grep eims_server_terminal | awk '{print $2}' | head -n1 | xargs kill -SIGINT
ps -ef | grep eims_server_terminal | awk '{print $2}' | head -n1 | xargs kill -SIGINT
echo "stop eims_server_terminal"
