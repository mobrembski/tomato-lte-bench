#!/bin/sh
# ping.sh - Ping statistics script
#
# Copyright 2016 Michał Obrembski
. common_rrd.sh
for host in $PING_HOSTS
do
    echo "Testing ping to host "$host
    db=$DBFOLDER$'/ping_'$host'.rrd'

    if [ ! -e $db ]
    then 
        echo "Database not found. Creating..."
        $rrdtool create $db --step 60 \
        DS:lost:GAUGE:600:0:U \
        DS:min:GAUGE:600:0:U \
        DS:max:GAUGE:600:0:U \
        DS:avg:GAUGE:600:0:U \
        RRA:AVERAGE:0.5:2:1400 \
        RRA:AVERAGE:0.5:10:1008 \
        RRA:AVERAGE:0.5:6:744 \
        RRA:AVERAGE:0.5:12:744 \
        RRA:AVERAGE:0.5:180:372 \
        RRA:AVERAGE:0.5:360:744

    fi

        output=`ping -c 2 -W 1 -q $host`
        recvd=`echo $output | grep  -o '[0-9]\+ packets received' | awk '{print $1}'`
        transmd=`echo $output | grep  -o '[0-9]\+ packets transmitted' | awk '{print $1}'`
        lost=`expr $transmd - $recvd`
        stats=`echo $output | grep -o '[0-9.]\+/[0-9.]\+/[0-9.]\+' | tr '/' ' '`
        min=`echo $stats | awk '{print $1}'`
        max=`echo $stats | awk '{print $3}'`
        avg=`echo $stats | awk '{print $2}'`

    $rrdtool update $db -t lost:min:max:avg N:$lost:$min:$max:$avg

    for period in $PERIODS
    do
        echo "Creating image for host "$host" for period "$period
        $rrdtool graph $IMGFOLDER/ping-$host-$period.png -s -1$period \
        -t "Ping to "$host" in the last $period" \
        --height $RRDHEIGHT \
        --width $RRDWIDTH \
        $OPTS \
        $CUST_COLOR \
        -l 0 -v "ms" \
        DEF:Lost=$db:lost:AVERAGE \
        DEF:Min=$db:min:AVERAGE \
        DEF:Max=$db:max:AVERAGE \
        DEF:Avg=$db:avg:AVERAGE \
        VDEF:lostmin=Lost,MINIMUM \
        VDEF:minmin=Min,MINIMUM \
        VDEF:maxmin=Max,MINIMUM \
        VDEF:avgmin=Avg,MINIMUM \
        VDEF:lostmax=Lost,MAXIMUM \
        VDEF:minmax=Min,MAXIMUM \
        VDEF:maxmax=Max,MAXIMUM \
        VDEF:avgmax=Avg,MAXIMUM \
        VDEF:lostlast=Lost,LAST \
        VDEF:minlast=Min,LAST \
        VDEF:maxlast=Max,LAST \
        VDEF:avglast=Avg,LAST \
        VDEF:lostavg=Lost,AVERAGE \
        VDEF:minavg=Min,AVERAGE \
        VDEF:maxavg=Max,AVERAGE \
        VDEF:avgavg=Avg,AVERAGE \
        "COMMENT: \l" \
        "COMMENT:                " \
        "COMMENT:Minimum       " \
        "COMMENT:Maximum       " \
        "COMMENT:Average       " \
        "COMMENT:Current      \l" \
        "COMMENT:   " \
        "AREA:Max#FF0000:Maximum   " \
        "GPRINT:maxmin:%3.0lf ms        " \
        "GPRINT:maxmax:%3.0lf ms        " \
        "GPRINT:maxavg:%3.0lf ms        " \
        "GPRINT:maxlast:%3.0lf ms     \l" \
        "COMMENT:   " \
        "AREA:Min#006600:Minimum   " \
        "GPRINT:minmin:%3.0lf ms        " \
        "GPRINT:minmax:%3.0lf ms        " \
        "GPRINT:minavg:%3.0lf ms        " \
        "GPRINT:minlast:%3.0lf ms     \l" \
        "COMMENT:   " \
        "LINE2:Avg#000099:Average   " \
        "GPRINT:avgmin:%3.0lf ms        " \
        "GPRINT:avgmax:%3.0lf ms        " \
        "GPRINT:avgavg:%3.0lf ms        " \
        "GPRINT:avglast:%3.0lf ms     \l" \
        "COMMENT:   " \
        "LINE2:Lost#000000:Lost      " \
        "GPRINT:lostmin:%3.0lf ms        " \
        "GPRINT:lostmax:%3.0lf ms        " \
        "GPRINT:lostavg:%3.0lf ms        " \
        "GPRINT:lostlast:%3.0lf ms     \l" \
        "COMMENT:   " > /dev/null
    done
done
