# cups print server #
FROM ubuntu:focal
LABEL maintainer="Tadaen Sylvermane <jmgibson81@gmail.com>"

# needed for tzdata
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
	gnupg \
	curl && \
	ln -s /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime

COPY entrypoint.sh /entrypoint.sh

RUN apt update && apt -y install \
	cups \
	patch \
	hplip && \
	chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
