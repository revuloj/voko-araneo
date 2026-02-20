#!/bin/bash

MARIADB_TLS_DISABLE_PEER_VERIFICATION=1

case $1 in

tls)
ssl)
  openssl s_client -connect abelo:3306 -starttls mysql -CAfile /usr/local/share/ca-certificates/mysql-ca.crt
  ;;
mysql)
  mysql -u s314802_3159000 -p -h abelo -P 3306 db314802x3159000
  ;;
dbi)
  # vd cgi/admin/dbtest.pl...
  ;;
esac