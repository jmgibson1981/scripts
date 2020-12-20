# no frills repository mythtv backend #
FROM ubuntu:focal

# needed for tzdata
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y --no-install-recommends \
        curl && \
        ln -s /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime

RUN apt update && apt install -y --no-install-recommends \
	wget \
	ssh \
	x11-apps \
	sudo \
	xauth \
	xvfb \
	mythtv-backend \
	libdbi-perl \
	cron \
	mariadb-server \
	tzdata \
	xmltv-util \
	libmythtv-perl && \
	rm -r /var/lib/apt/lists/* && \
	apt -y --purge autoremove curl


COPY start.source /entrypoint.sh
RUN wget -O /root/optimize_mythdb.pl \
	https://raw.githubusercontent.com/MythTV/mythtv/master/mythtv/contrib/maintenance/optimize_mythdb.pl && \
	chmod 755 /root/optimize_mythdb.pl && \
	chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]


