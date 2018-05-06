#!/bin/sh

scriptfolder=script
binfolder=bin
systemconfigfile=eims_server_terminal_system.ini
logicconfigfile=eims_server_terminal_logic.ini

if [ ! -d "$scriptfolder" ]; then
echo "have no script folder"
exit 1
fi

if [ ! -d "$binfolder" ]; then
echo "have no lib(bin) folder"
exit 1
fi

if [ ! -f "$systemconfigfile" ]; then
echo "have no system config file"
exit 1
fi

if [ ! -f "$logicconfigfile" ]; then
echo "have no logic config file"
exit 1
fi

curpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LD_LIBRARY_PATH=$curpath/bin ./eims_server_terminal &

echo "========================================="
echo "========================================="
echo "==== 				   ===="
echo "==== eims_server_terminal run sucess ===="
echo "====                                 ===="
echo "========================================="


exit 1


