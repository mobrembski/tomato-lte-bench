#!/bin/sh
FTP_HOST="lte.byku.com.pl"
cd /tmp
while :
do
	ftpget -v $FTP_HOST testfile
	rm testfile
	if [ ! -e testfile_up ]
	then
		echo "Creating 5MB upload test file"
		dd if=/dev/urandom of=testfile_up bs=1M count=5
	fi
	ftpput -v $FTP_HOST testfile_up
	sleep 30
done
