#!/bin/sh
# tadaen sylvermane | jason gibson
# print server entrypoint for docker

service cups start
cupsctl --remote-admin

echo "--- /etc/cups/cupsd.conf        2020-12-19 07:31:37.010741864 -0700
+++ /root/cupsd.cnfmod  2020-12-19 07:32:33.997439712 -0700
@@ -1,9 +1,12 @@
 LogLevel warn
+DefaultEncryption IfRequested
+ServerAlias print.mylan.home:631
 PageLogFormat
 MaxLogSize 0
 # Allow remote access
 Port 631
-Listen /run/cups/cups.sock
+#Listen /run/cups/cups.sock
+Listen 0.0.0.0:631
 Browsing Off
 BrowseLocalProtocols dnssd
 DefaultAuthType Basic
@@ -12,11 +15,13 @@
   # Allow remote administration...
   Order allow,deny
   Allow @LOCAL
+  Allow 192.168.1.*
 </Location>
 <Location /admin>
   # Allow remote administration...
   Order allow,deny
   Allow @LOCAL
+  Allow 192.168.1.*
 </Location>
 <Location /admin/conf>
   AuthType Default
@@ -24,6 +29,7 @@
   # Allow remote access to the configuration files...
   Order allow,deny
   Allow @LOCAL
+  Allow 192.168.1.*
 </Location>
 <Location /admin/log>
   AuthType Default
@@ -31,6 +37,7 @@
   # Allow remote access to the log files...
   Order allow,deny
   Allow @LOCAL
+  Allow 192.168.1.*
 </Location>
 <Policy default>
   JobPrivateAccess default" > /cupspatch.patch
patch /etc/cups/cupsd.conf < /cupspatch.patch

adduser --no-create-home --gecos --system --disabled-password printers
echo printers:printers | chpasswd printers
usermod -aG lpadmin printers

service cups restart && bash

