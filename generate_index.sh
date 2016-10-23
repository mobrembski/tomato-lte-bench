#!/bin/sh
# generate_index.sh - Simple script to generate index.html
#
# Copyright 2016 Michał Obrembski
. common_rrd.sh
INDEXFILE=$IMGFOLDER/index.html
if [ ! -e $INDEXFILE ]
then
    echo "Index.html not found, creating new one.."
    echo "<html><body>" >> $INDEXFILE
    for file in $IMGFOLDER/*.png
    do
        filename=`basename $file`
        echo "<img src=\""$filename"\"/>" >> $INDEXFILE
    done
    echo "</body></html>" >> $INDEXFILE
fi
