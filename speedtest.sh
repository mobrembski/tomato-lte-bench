#!/bin/sh
# speedtest.sh - Network speed statistics using speedtest
#
# Copyright 2016 Michał Obrembski
cd `dirname $0`

. common_rrd.sh
echo "Testing network speed via speedtest.net"
db=$DBFOLDER$'/speedtest.rrd'

if [ ! -e $db ]
then
    echo "Database not found, creating a new one..."
    $rrdtool create $db --step 900 \
    DS:download:GAUGE:2700:0:U \
    DS:upload:GAUGE:2700:0:U \
    RRA:AVERAGE:0.5:1:120 \
    RRA:AVERAGE:0.5:6:90 \
    RRA:AVERAGE:0.5:40:50 \
    RRA:AVERAGE:0.5:100:20 
fi

$BINFOLDER/SpeedTestC --randomize 10 --downtimes 3 >> /tmp/speedtestout
downloaded=`cat /tmp/speedtestout | grep downloaded | grep -o '([0-9.]\+ kb/s)' | tr ')' ' ' | tr '(' ' ' | awk '{print $1}'`
uploaded=`cat /tmp/speedtestout | grep uploaded | grep -o '([0-9.]\+ kb/s)' | tr ')' ' ' | tr '(' ' ' | awk '{print $1}'`
rm /tmp/speedtestout
$rrdtool update $db -t download:upload N:$downloaded:$uploaded
LOGLINE=`date`" Download: "$downloaded"kbps Upload: "$uploaded"kbps"
echo $LOGLINE >> $LOGFOLDER/speedtest.log
echo $LOGLINE

for period in $PERIODS
do
    echo "Generating speedtest graph for period "$period
    $rrdtool graph $IMGFOLDER/speedtest-$period.png -s -1$period \
    -t "Speedtest in $period" \
    --height $RRDHEIGHT \
    --width $RRDWIDTH \
    $OPTS \
    $CUST_COLOR \
    -l 0 -v "Mb/s" \
    DEF:downdb=$db:download:AVERAGE \
    DEF:updb=$db:upload:AVERAGE \
    CDEF:download=downdb,1000,* \
    CDEF:upload=updb,1000,* \
    VDEF:minin=upload,MINIMUM \
    VDEF:minout=download,MINIMUM \
    VDEF:maxin=upload,MAXIMUM \
    VDEF:maxout=download,MAXIMUM \
    VDEF:avgin=upload,AVERAGE \
    VDEF:avgout=download,AVERAGE \
    VDEF:lstin=upload,LAST \
    VDEF:lstout=download,LAST \
    VDEF:totin=upload,TOTAL \
    VDEF:totout=download,TOTAL \
    "COMMENT: \l" \
    "COMMENT:                    " \
    "COMMENT:Minimum      " \
    "COMMENT:Maximum      " \
    "COMMENT:Average      " \
    "COMMENT:Current      \l" \
    "COMMENT:   " \
    "AREA:download#EDA362:Download  " \
    "LINE1:download#F47200" \
    "GPRINT:minout:%5.1lf %sb/s   " \
    "GPRINT:maxout:%5.1lf %sb/s   " \
    "GPRINT:avgout:%5.1lf %sb/s   " \
    "GPRINT:lstout:%5.1lf %sb/s \l" \
    "COMMENT:   " \
    "AREA:upload#8AD3F1:Upload    " \
    "LINE1:upload#49BEEF" \
    "GPRINT:minin:%5.1lf %sb/s   " \
    "GPRINT:maxin:%5.1lf %sb/s   " \
    "GPRINT:avgin:%5.1lf %sb/s   " \
    "GPRINT:lstin:%5.1lf %sb/s  \l" > /dev/null

done
