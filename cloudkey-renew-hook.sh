#!/bin/bash
# Courtesy of Gerd W. Naschenweng (https://www.naschenweng.info/2017/01/06/securing-ubiquiti-unifi-cloud-key-encrypt-automatic-dns-01-challenge/)
# Renew-hook for ACME / Let's encrypt
echo "** Configuring new Let's Encrypt certs"
cd /etc/ssl/private
rm -f /etc/ssl/private/cert.tar /etc/ssl/private/unifi.keystore.jks /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/fullchain.pem

openssl pkcs12 -export -in /etc/ssl/private/cloudkey.crt -inkey /etc/ssl/private/cloudkey.key -out /etc/ssl/private/cloudkey.p12 -name unifi -password pass:aircontrolenterprise

keytool -importkeystore -deststorepass aircontrolenterprise -destkeypass aircontrolenterprise -destkeystore /usr/lib/unifi/data/keystore -srckeystore /etc/ssl/private/cloudkey.p12 -srcstoretype PKCS12 -srcstorepass aircontrolenterprise -alias unifi

rm -f /etc/ssl/private/cloudkey.p12
tar -cvf cert.tar *
chown root:ssl-cert /etc/ssl/private/*
chmod 640 /etc/ssl/private/*

echo "** Testing Nginx and restarting"
/usr/sbin/nginx -t
/etc/init.d/nginx restart ; /etc/init.d/unifi restart
