#!/bin/sh
cd `dirname $0`
. common_rrd.sh
BENCH_SCRIPT=`pwd`/bench_all.sh
if [ ! -e $IMGFOLDER ]
then
  mkdir $IMGFOLDER
fi
if [ -e $CGIFOLDER/getrrd.cgi ]
then
  exit 0
fi

cp www/getrrd.cgi $CGIFOLDER/getrrd.cgi
sed -i "s|^\(host=\).*|\1'$HTTP_HOST'|" $CGIFOLDER/getrrd.cgi
sed -i "s|^\(imgfolder=\).*|\1'$IMGFOLDER'|" $CGIFOLDER/getrrd.cgi
sed -i "s|^\(benchscript=\).*|\1'$BENCH_SCRIPT'|" $CGIFOLDER/getrrd.cgi

cp www/index.html $CGIFOLDER/index.html
sed -i "s|\(var data_file = \).*|\1'$HTTP_HOST_CGI"/getrrd.cgi"'|" $CGIFOLDER/index.html
