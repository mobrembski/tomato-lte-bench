#!/bin/sh
# ltemodemquality.sh - LTE modem quality statistics script
# Currently tested with Huawei E3372 no-hilink version.
# Due to lack of diagnostic interface it won't work on hilink versions.
#
# Copyright 2016 Michał Obrembski
. common_rrd.sh
echo "Testing LTE modem"
db=$DBFOLDER$'/ltemodem.rrd'

if [ ! -e $db ]
then 
    echo "Database not found, creating a new one..."
    $rrdtool create $db --step 180 \
    DS:rssi:GAUGE:360:U:U \
    DS:rsrp:GAUGE:360:U:U \
    DS:sinr:GAUGE:360:U:U \
    DS:rsrq:GAUGE:360:U:U \
    RRA:AVERAGE:0.5:1:500 \
    RRA:AVERAGE:0.5:5:300 \
    RRA:AVERAGE:0.5:20:200 \
    RRA:AVERAGE:0.5:80:200 \
    RRA:AVERAGE:0.5:240:200 \
    RRA:AVERAGE:0.5:480:365
fi
# Code from switch4g script. Apparently in switch4g it doesnt work well. Here is working correctly
HCSQ=`MODE="AT^HCSQ?" gcom -d $MODEM_IFACE -s /etc/gcom/setverbose.gcom | grep "HCSQ:" | tr -d '\r'`
SPEED=`echo $HCSQ | cut -d "," -f1 | cut -d '"' -f2`
case "$SPEED" in
    "LTE")
            VALUE=`echo $HCSQ | cut -d "," -f2`
            RSSI=`awk "BEGIN {print -120+$VALUE}"` #dBm
            VALUE=`echo $HCSQ | cut -d "," -f3`
            RSRP=`awk "BEGIN {print -140+$VALUE}"` #dBm
            VALUE=`echo $HCSQ | cut -d "," -f4`
            SINR=`awk "BEGIN {print -20+$VALUE*0.2}"` #dB
            VALUE=`echo $HCSQ | cut -d "," -f5`
            RSRQ=`awk "BEGIN {print -19.5+$VALUE*0.5}"` #dB
    ;;
    "WCDMA")
            VALUE=`echo $HCSQ | cut -d "," -f2`
            RSSI=`awk "BEGIN {print -120+$VALUE}"` #dBm
            VALUE=`echo $HCSQ | cut -d "," -f3`
            RSRP=`awk "BEGIN {print -120+$VALUE}"` #dBm
            VALUE=`echo $HCSQ | cut -d "," -f4`
            ECIO=`awk "BEGIN {print -32+$VALUE*0.5}"` #dB
    ;;
    "GSM")
            VALUE=`echo $HCSQ | cut -d "," -f2`
            RSSI=`awk "BEGIN {print -120+$VALUE}"` #dBm
    ;;
esac

LOGLINE=`date`" Modem speed: "$SPEED" Signal Strength: RSSI "$RSSI" dBm, RSRP "$RSRP" dBm, SINR "$SINR" dB, RSRQ "$RSRQ" dB"
echo $LOGLINE >> $LOGFOLDER/ltemodem.log
echo $LOGLINE
$rrdtool update $db -t rssi:rsrp:sinr:rsrq N:$RSSI:$RSRP:$SINR:$RSRQ

for period in $PERIODS
do
    echo "Generating modem graph for period "$period
    $rrdtool graph $IMGFOLDER/lte-$period.png -s -1$period \
    -t "LTE signal in $period" \
    --height $RRDHEIGHT \
    --width $RRDWIDTH \
    $OPTS \
    $CUST_COLOR \
    -v "dBm" \
    -u 5  \
    "DEF:rssi=$db:rssi:AVERAGE" \
    "DEF:rsrp=$db:rsrp:AVERAGE" \
    "DEF:sinr=$db:sinr:AVERAGE" \
    "DEF:rsrq=$db:rsrq:AVERAGE" \
    "VDEF:rssiavg=rssi,AVERAGE" \
    "VDEF:rsrpavg=rsrp,AVERAGE" \
    "VDEF:sinravg=sinr,AVERAGE" \
    "VDEF:rsrqavg=rsrq,AVERAGE" \
    "VDEF:rssilast=rssi,LAST" \
    "VDEF:rsrplast=rsrp,LAST" \
    "VDEF:sinrlast=sinr,LAST" \
    "VDEF:rsrqlast=rsrq,LAST" \
    "VDEF:rssimin=rssi,MINIMUM" \
    "VDEF:rsrpmin=rsrp,MINIMUM" \
    "VDEF:sinrmin=sinr,MINIMUM" \
    "VDEF:rsrqmin=rsrq,MINIMUM" \
    "VDEF:rssimax=rssi,MAXIMUM" \
    "VDEF:rsrpmax=rsrp,MAXIMUM" \
    "VDEF:sinrmax=sinr,MAXIMUM" \
    "VDEF:rsrqmax=rsrq,MAXIMUM" \
    "COMMENT: \l" \
    "COMMENT:                    " \
    "COMMENT:Minimum      " \
    "COMMENT:Maximum      " \
    "COMMENT:Average      " \
    "COMMENT:Current      \l" \
    "COMMENT:   " \
    "AREA:rsrp#FF9900:RSRP       " \
    "GPRINT:rsrpmin:%2.1lf dBm    " \
    "GPRINT:rsrpmax:%2.1lf dBm    " \
    "GPRINT:rsrpavg:%2.1lf dBm    " \
    "GPRINT:rsrplast:%2.1lf dBm    \l" \
    "COMMENT:   " \
    "AREA:rssi#FF0000:RSSI       " \
    "GPRINT:rssimin:%2.1lf dBm    " \
    "GPRINT:rssimax:%2.1lf dBm    " \
    "GPRINT:rssiavg:%2.1lf dBm    " \
    "GPRINT:rssilast:%2.1lf dBm    \l" \
    "COMMENT:   " \
    "AREA:rsrq#6666FF:RSRQ       " \
    "GPRINT:rsrqmin:%2.1lf dB       " \
    "GPRINT:rsrqmax:%2.1lf dB      " \
    "GPRINT:rsrqavg:%2.1lf dB      " \
    "GPRINT:rsrqlast:%2.1lf dB      \l" \
    "COMMENT:   " \
    "AREA:sinr#339900:SINR        " \
    "GPRINT:sinrmin:%2.1lf dB     " \
    "GPRINT:sinrmax:%2.1lf dB     " \
    "GPRINT:sinravg:%2.1lf dB     " \
    "GPRINT:sinrlast:%2.1lf dB    " > /dev/null

done

