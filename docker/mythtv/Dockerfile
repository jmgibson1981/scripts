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
	libmythtv-perl && \
	rm -r /var/lib/apt/lists/* && \
	apt -y --purge autoremove curl

COPY start.source /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]


