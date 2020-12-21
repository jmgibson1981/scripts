# no frills repository installation of mariadb-server #
FROM ubuntu:focal
LABEL maintainer="Tadaen Sylvermane <jmgibson81@gmail.com>"

# needed for tzdata
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
	curl && \
	ln -s /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime

COPY start.source /entrypoint.sh

# install & cleanup #

RUN apt install -y --no-install-recommends \
	tzdata \
	mariadb-server && \
	rm -r /var/lib/apt/lists/* && \
	apt --purge autoremove -y curl && \
	chmod 755 /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]
