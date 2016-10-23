#!/bin/sh
cd `dirname $0`
. common_rrd.sh
cputype=`uname -m`
if [ ! -e $BINFOLDER ]
then
        echo "Sorry, your platform "$cputype" is currently not supported by this script"
        exit 1
fi
./ltemodemquality.sh
./network.sh
./ping.sh
./speedtest.sh
./generate_index.sh
#./vpn2.sh
