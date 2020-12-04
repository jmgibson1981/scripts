# no frills repository mythtv backend #
FROM ubuntu:focal

# needed for tzdata
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
	curl && \
	ln -s /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime

RUN apt install -y --no-install-recommends \
	rsyslog \
	nano \
	ssh \
	x11-apps \
	sudo \
	xauth \
	xvfb \
	mythtv-backend \
	libdbi-perl \
	cron \
	tzdata \
	mariadb-server \
	libmythtv-perl && \
	apt clean && \
	rm -r /var/lib/apt/lists/* && \
	echo "mythtv ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/mythtv && \
	apt -y --purge autoremove curl

COPY config.xml /etc/mythtv/config.xml
COPY sshd_config /etc/ssh/sshd_config
COPY rootcrontab /var/spool/cron/crontabs/root
# https://github.com/MythTV/mythtv/blob/master/mythtv/contrib/maintenance/optimize_mythdb.pl
# need to download this manually to your docker build folder. probably can be gotten with wget during
# build process. still tinkering.
COPY optimize_mythdb.pl /usr/share/doc/mythtv-backend/contrib/maintenance/
COPY 99-mythtv.cnf /etc/mysql/mariadb.conf.d/
COPY envsetup.source /usr/local/bin/
COPY mythdbcreate /usr/local/bin/
RUN chown mythtv:mythtv /etc/mythtv/config.xml && echo "mythtv:mythtv" | chpasswd && \
	chmod 755 /usr/share/doc/mythtv-backend/contrib/maintenance/optimize_mythdb.pl && \
	chmod 600 /var/spool/cron/crontabs/root && \
	chown root:crontab /var/spool/cron/crontabs/root && \
	chmod 755 /usr/local/bin/envsetup.source


