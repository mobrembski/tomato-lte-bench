#!/bin/sh
cd `dirname $0`
. common_rrd.sh
cputype=`uname -m`
if [ ! -e $BINFOLDER ]
then
        echo "Sorry, your platform "$cputype" is currently not supported by this script"
        exit 1
fi
./install_cgi.sh

for script in rrdscripts/*.sh
do
	. $script
	if [ "$1" = "graph" ]
	then
		graph "$2"
	else
		update
	fi
done
