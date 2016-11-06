#!/bin/sh

FOUND_GET_PARAM="0";
OIFS="$IFS"
IFS="${IFS}&"
set -e $QUERY_STRING
Args="$*"
IFS="$OIFS"
for i in $Args; do
IFS="${OIFS}="
set $i
IFS="${OIFS}"
case $1 in
	period) period="`echo $2 | sed 's|[\]||g' | sed 's|%20| |g'`"
		FOUND_GET_PARAM="1"
		;;
esac
done

if [ $FOUND_GET_PARAM -eq "0" ]
then
	period="hour"
fi

host='https://lte.byku.com.pl:8443/ext/rrd'
benchscript='/tmp/tomato-lte-bench/bench_all.sh'
imgfolder='/www/ext/rrd'
$benchscript graph $period > /dev/null

echo -ne ' { "img": ['
for png in $imgfolder/*$period.png
do
	pngfile=`basename $png`
	echo -ne '"'$host'/'$pngfile'"'
	echo -ne ", "
done
echo -ne '"" ] }'
