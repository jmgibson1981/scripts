# squid docker from repositories with ssl bump #
# minimum required to be able to run and configure #
FROM ubuntu:focal
LABEL maintainer="Tadaen Sylvermane <jmgibson81@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILDPACKAGES="dpkg-dev build-essential packaging-dev equivs lintian \
	fakeroot devscripts gawk gcc-multilib dpatch libssl-dev"
ENV STAYPACKAGES="openssl apache2 squid-langpack logrotate libdbi-perl ssl-cert"

# added source line for future squid source download. rest of RUN section here
# needed for tzdata - source
# https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

RUN echo "deb-src http://archive.ubuntu.com/ubuntu focal main" >> \
	/etc/apt/sources.list && \
	apt update && apt install -y \
	curl && \
	ln -s /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime

# https://elatov.github.io/2019/01/using-squid-to-proxy-ssl-sites/
# https://www.vultr.com/docs/how-to-compile-squid3-on-ubuntu-12-04
# https://serverfault.com/questions/987363/squid-proxy-using-https

RUN apt install -y ${BUILDPACKAGES} ${STAYPACKAGES} && \
	apt build-dep -y squid openssl && \
	cd /root && \
	apt source squid && \
	cd squid-[0-9].[0-9][0-9] && \
	sed -i \
	's/--with-gnutls/--with-gnutls --enable-ssl --with-cppunit-basedir=\/usr \
	--enable-ssl-crtd --with-openssl/' debian/rules && \
	debuild -us -uc -b && \
	dpkg -i /root/squid*.deb && \
	apt install -fy && \
	rm -r /root/* && \
	apt clean && \
	# this and the later removal of password is to prevent autoremove from
	# complaining about removing sudo. eliminates a useless prompt basically.
	echo "root:root" | chpasswd && \
	apt --purge autoremove -y ${BUILDPACKAGES} && \
	passwd -d root && \
	rm -r /var/lib/apt/lists/*

COPY squidcert.source /usr/local/bin/squidcert.source
RUN chmod 755 /usr/local/bin/squidcert.source





