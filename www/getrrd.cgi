#!/bin/sh
period="hour"
host="https://lte.byku.com.pl:8443/ext/rrd/"
benchscript=/tmp/tomato-lte-bench/bench_all.sh
imgfolder=/www/ext/rrd
$benchscript graph $period > /dev/null

echo -ne ' { "img": ['
for png in $imgfolder/*$period.png
do
	pngfile=`basename $png`
	echo -ne '"'$host'/'$pngfile'"'
	echo -ne ", "
done
echo -ne '"" ] }'
