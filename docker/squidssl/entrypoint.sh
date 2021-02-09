#!/bin/sh
# tadaen sylvermane | jason gibson
# source for squid ssl docker container init script

# variables #

# directory to put certificates #

CERTSDIR=/etc/squid/certs

# openssl keygen variables - customize these #

COUNTRY="US"
STATE="AZ"
CITY="TUCSON"
ORGANIZATION="JYG SERVICES"
ORGANIZATIONUNIT="LAN"
COMMONNAME="JASON GIBSON"
EMAIL="JMGIBSON81@GMAIL.COM"
DAYS="36500"

# begin script #

if [ ! "$(ls -A ${CERTSDIR})" ] ; then
	mkdir -p "$CERTSDIR"
	openssl req \
		-new \
		-newkey rsa:2048 \
		-sha256 \
		-days "$DAYS" \
		-nodes \
		-x509 \
		-extensions v3_ca \
		-keyout "$CERTSDIR"/myCA.pem \
		-out "$CERTSDIR"/myCA.pem \
		-subj "/C=${COUNTRY}/" \
		-subj "/ST=${STATE}/" \
		-subj "/L=${CITY}/" \
		-subj "/O=${ORGANIZATION}/" \
		-subj "/OU=${ORGANIZATIONUNIT}/" \
		-subj "/CN=${COMMONNAME}/" \
		-subj "/emailAddress=${EMAIL}"
	openssl x509 -outform DER -in "$CERTSDIR"/myCA.pem \
	-out "$CERTSDIR"/SQUID-CA-FOR-IMPORT.der
	chown -R proxy:proxy "$CERTSDIR"
	chmod 700 "$CERTSDIR" && chmod 744 "$CERTSDIR"/*.pem
	/usr/lib/squid/security_file_certgen -c -s /var/spool/squid/ssl_db -M 20MB
	chown -R proxy:proxy /var/spool/squid/ssl_db
fi

[ -e /var/run/squid.pid ] && rm /var/run/squid.pid
service squid start
exec bash

# end script #
