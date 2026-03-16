#!/bin/bash

# aldonu tiun ĉi skripton al docker-entrypoint.sh
# se vi volas kontroli la CA, kaj tiukaze ankaŭ forigu la
# variablon MARIADB_TLS_DISABLE_PEER_VERIFICATION en Dockerfile
#set -x

echo q | openssl s_client -starttls mysql -connect abelo:3306 -showcerts 2>/dev/null \
       | openssl x509 -outform PEM > cert0.pem
#       | awk '/^[ \t]+CA Issuers[ \t]+-[ \t]+URI:/ { print gensub(/^.*URI:(.*)$/,"\\1","g",$0); }'
#       | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; print a}'
#       | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out="cert"a".pem"; print > out}'


#openssl x509 -noout -text -in $1 | awk '/^[ \t]+CA Issuers[ \t]+-[ \t]+URI:/ { print gensub(/^.*URI:(.*)$/,"\\1","g",$0); }'


abelo_ip=$(getent hosts abelo | awk '{ print $1 }')
abelo_name=$(openssl x509 -in cert0.pem -noout -subject | sed 's/.*CN[ ]*=[ ]*//')

echo "${abelo_ip} abelo ${abelo_name}"

mv cert0.pem /usr/local/share/ca-certificates/mysql-ca.crt
update-ca-certificates
#rm cert*.pem

# ĉu bone importita?
openssl crl2pkcs7 -nocrl -certfile /etc/ssl/certs/ca-certificates.crt \
  | openssl pkcs7 -print_certs -noout \
  | tail


echo "${abelo_ip} abelo ${abelo_name}" >> /etc/hosts

# testo :
# mysql  -h abelo -u s314802_3159000 -D db314802x3159000 -p --ssl-ca=/usr/local/share/mysql-ca.crt



