#!/bin/sh
# network.sh - Network usage stats
#
# Copyright 2010 Frode Petterson. All rights reserved.
# See README.rdoc for license.
. common_rrd.sh

function create {
	if [ ! -e $db ]
	then
		echo "Database not found...Creating a new one"
		$rrdtool create $db \
		DS:in:DERIVE:600:0:12500000 \
		DS:out:DERIVE:600:0:12500000 \
		RRA:AVERAGE:0.5:1:576 \
		RRA:AVERAGE:0.5:6:672 \
		RRA:AVERAGE:0.5:24:732 \
		RRA:AVERAGE:0.5:144:1460
	fi
}

function update {
	for if in $IFACES_SPEED
	do
		echo "Probing transfered bytes from interface "$if
		db=$DBFOLDER$'/network_'$if'.rrd'
		create

		$rrdtool update $db N:`/sbin/ifconfig $if |grep bytes|cut -d":" -f2|cut -d" " -f1`:`/sbin/ifconfig $if |grep bytes|cut -d":" -f3|cut -d" " -f1`
	done
}

function graph {
	local period=$1
	for if in $IFACES_SPEED
	do
		db=$DBFOLDER$'/network_'$if'.rrd'
		echo "Generating graph for interface "$if" for period "$period
		$rrdtool graph $IMGFOLDER/network-$if-$period.png -s -1$period \
		-t "Network traffic the last $period" \
		$CUST_COLOR \
		$OPTS \
		--width $RRDWIDTH \
		--height $RRDHEIGHT \
		-l 0 -a PNG -v "B/s" \
		DEF:in=$db:in:AVERAGE \
		DEF:out=$db:out:AVERAGE \
		VDEF:minin=in,MINIMUM \
		VDEF:minout=out,MINIMUM \
		VDEF:maxin=in,MAXIMUM \
		VDEF:maxout=out,MAXIMUM \
		VDEF:avgin=in,AVERAGE \
		VDEF:avgout=out,AVERAGE \
		VDEF:lstin=in,LAST \
		VDEF:lstout=out,LAST \
		VDEF:totin=in,TOTAL \
		VDEF:totout=out,TOTAL \
		"COMMENT: \l" \
		"COMMENT:               " \
		"COMMENT:Minimum      " \
		"COMMENT:Maximum      " \
		"COMMENT:Average      " \
		"COMMENT:Current      " \
		"COMMENT:Total        \l" \
		"COMMENT:   " \
		"AREA:out#EDA362:Out  " \
		"LINE1:out#F47200" \
		"GPRINT:minout:%5.1lf %sB/s   " \
		"GPRINT:maxout:%5.1lf %sB/s   " \
		"GPRINT:avgout:%5.1lf %sB/s   " \
		"GPRINT:lstout:%5.1lf %sB/s   " \
		"GPRINT:totout:%5.1lf %sB   \l" \
		"COMMENT:   " \
		"AREA:in#8AD3F1:In   " \
		"LINE1:in#49BEEF" \
		"GPRINT:minin:%5.1lf %sB/s   " \
		"GPRINT:maxin:%5.1lf %sB/s   " \
		"GPRINT:avgin:%5.1lf %sB/s   " \
		"GPRINT:lstin:%5.1lf %sB/s   " \
		"GPRINT:totin:%5.1lf %sB   \l" > /dev/null
	done
}
