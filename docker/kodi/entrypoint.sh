#!/bin/sh
# tadaen sylvermane | jason gibson

# begin script #

if [ ! -f /root/startup.sh ] ; then
	echo "tcp:192.168.1.43:4713" > /root/pulseserver
	echo "x11vnc -forever &
kodi" > /root/startup.sh
	chmod 755 /root/startup.sh
	[ -d /root/.config/pulse ] || mkdir -p /root/.config/pulse
	cp /etc/pulse/default.pa /root/.config/pulse/
	echo "--- /etc/pulse/default.pa       2020-10-15 14:23:31.000000000 -0700
+++ /root/default.pa    2020-12-17 10:06:06.830293371 -0700
@@ -80,8 +80,9 @@
 ### Network access (may be configured with paprefs, so leave this commented
 ### here if you plan to use paprefs)
 #load-module module-esound-protocol-tcp
-#load-module module-native-protocol-tcp
+load-module module-native-protocol-tcp
 #load-module module-zeroconf-publish
+load-module module-zeroconf-discover

 ### Load the RTP receiver module (also configured via paprefs, see above)
 #load-module module-rtp-recv"  > /root/pulsepatch.patch
	patch /root/.config/pulse/default.pa < /root/pulsepatch.patch
fi

# set pulse server #

export PULSE_SERVER=$(cat /root/pulseserver)

# run vnc & kodi #

xvfb-run /root/startup.sh && bash

# end script #
