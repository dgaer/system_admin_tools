#!/bin/bash

HOSTNAME=$(hostname -s)
openssl genrsa -out /etc/pki/tls/private/${HOSTNAME}.key 2048
openssl req -new -key /etc/pki/tls/private/${HOSTNAME}.key -out /etc/pki/tls/certs/${HOSTNAME}.csr
openssl x509 -req -days 9999 -in /etc/pki/tls/certs/${HOSTNAME}.csr -signkey /etc/pki/tls/private/${HOSTNAME}.key -out /etc/pki/tls/certs/${HOSTNAME}.crt

cp -fp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.org
sed -i s,"SSLCertificateFile /etc/pki/tls/certs/localhost.crt","SSLCertificateFile /etc/pki/tls/certs/${HOSTNAME}.crt",g /etc/httpd/conf.d/ssl.conf
sed -i s,"SSLCertificateKeyFile /etc/pki/tls/private/localhost.key","SSLCertificateKeyFile /etc/pki/tls/private/${HOSTNAME}.key",g /etc/httpd/conf.d/ssl.conf

systemctl restart httpd

