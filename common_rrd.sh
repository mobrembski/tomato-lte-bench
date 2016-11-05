#!/bin/ash
# NOTE: All directories and URLs defined here should be without ending slash
# A directory where script has been putted.
BASEFOLDER='/tmp/tomato-lte-bench'
# A directory where RRDs are placed
DBFOLDER=$BASEFOLDER'/db'
# A directory where script logs are placed
LOGFOLDER=$BASEFOLDER'/logs'
# Folder where images and index.html has been put. Should be accessible by NGINX
IMGFOLDER='/www/ext/rrd'
# Folder where CGI scripts are placed
CGIFOLDER='/www/ext/cgi-bin'
# Width of images
RRDWIDTH='600'
# Height of images
RRDHEIGHT='100'
# Hosts to check with ping script. Space separated.
PING_HOSTS="facebook.com blog.byku.com.pl onet.pl 192.168.8.1"
# Network interfaces to check by network script. Space separated.
IFACES_SPEED="eth2 vlan2"
# Periods of time to draw on images. Space separated.
PERIODS="hour day week"
# LTE Modem diagnostic interface
MODEM_IFACE="/dev/ttyUSB0"
# HTTP URL where images are placed
HTTP_HOST="http://192.168.1.1/ext/rrd"
# HTTP URL where cgi scripts are accessible
HTTP_HOST_CGI="http://192.168.1.1/ext/cgi-bin"

# You shouldn't modify those values.
PLATFORM=`uname -m`
BINFOLDER=$BASEFOLDER'/bin/'$PLATFORM
export LD_LIBRARY_PATH=$BINFOLDER
CUST_COLOR='-c BACK#FFFFFF -c SHADEA#FFFFFF -c SHADEB#FFFFFF -c MGRID#AAAAAA -c GRID#CCCCCC -c ARROW#333333 -c FONT#333333 -c AXIS#333333 -c FRAME#333333'
OPTS='--font DEFAULT:0:'$BINFOLDER/'DejaVuSansMono-Roman.ttf'
rrdtool=$BINFOLDER/rrdtool
