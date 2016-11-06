# Tomato-lte-bench
A bunch of scripts to run on router for benchmarking LTE modem connection
# Overview

This repository contains several scripts to test an network connection on routers.
I've been asked to do an long-run tests in a company on new ISP provider.
The tests should consist of following parameters:
1. LTE Modem signal parameters
2. Ping tests on several domains
3. Available network bandwidth
4. VPN connection speed

To do all those tests i've used an Asus RT-N18U router with Tomato Firmware on it,
and RRDTool as an database and graphing tool.

# Installation
To install this scripts, just clone this repository on some writable storage on your router, and add executing bench_all.sh script every 3 minutes to the scheduler.
Configuration of scripts is stored inside common_rrd.sh. common_rrd.sh contains a lot of comments so it should be easy to understood.
I do not recommend JFFS2 as a storage for your scripts, because currently script are designed to update database every 3 minutes. This could kill fragile router flash chips easily.
Instead, you should connect an USB FlashDrive to your router, and copy all files every boot to /tmp partition.

You can access your graphs by opening index.html with your browser. By default address is http://192.168.1.1/ext/cgi-bin/index.html

# Technical details
Script use an undocumented feature in Tomato HTTPD server, which is CGI scripts gateway.
All scripts placed in /www/ext/cgi-bin with executable permission can be executed by HTTPD server, and result is redirected to user browser.
This behavior is used to run RRDTool to generate graphs, and then paths of images are returned to the browser in a form of JSON array.

If your firmware doesn't support CGI script, you can still run generate_index.sh script to create index.html along with graphs, and place it somewhere on accessible WWW server.
By default, generated graphs and index.html is stored in /tmp/www/rrd. Please make sure that your http server is able to serve this folder.

ftptest.sh script uses a behavior, that VSFTPD prints speed of every download and upload session to syslog. So the script looks for last occurence of reported speeds in syslog, and put it into RRD database.
Of course you need a second router or PC, which will make some FTP sessions. There is a simple script designed to make some FTP traffic using busybox. Please have a look at ftp_client.sh file.

# Description of scripts
ltemodemquality.sh - Scripts asks modem for radio quality parameters. It will only work with non-hilink modems, because it uses modem diagnostic interface. Currently tested with Huawei E3372s.

![Result of ltemodemquality](/screenshots/lte-day.png?raw=true "Result of ltemodemquality")

network.sh - Script grabs transferred bytes via provided interfaces and produces a graph showing speed and total transfered data.

![Result of network](/screenshots/network-eth2-day.png?raw=true "Result of network")

ping.sh - Script checks latency for provided hosts.

![Result of ping](/screenshots/ping-onet.pl-day.png?raw=true "Result of ping")

speedtest.sh - Script tests internet speed via Speedtest.net network.

![Result of speedtest](/screenshots/speedtest-day.png?raw=true "Result of speedtest")

ftptest.sh - Script checks logged speed of built-in vsftp FTP Server and plots a graph. You will need a second computer to make some traffic on FTP :-)
