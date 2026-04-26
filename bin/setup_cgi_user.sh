#!/bin/bash
set -x

DAEMON_UID=13731
#CGI_PASSWD=$(cat /run/secrets/voko-araneo.cgi_password)

# Eble plibonigu: 
# certigu ke cgi_password ne estu malplena!

htpasswd=/usr/local/apache2/conf/.htpasswd

sed -i "s|AuthUserFile .*|AuthUserFile ${htpasswd}|" /usr/local/apache2/cgi-bin/admin/.htaccess

if [ ! -e ${htpasswd} ]; then
  cat /run/secrets/voko-araneo.cgi_password | htpasswd -i -c ${htpasswd} araneo

  chown ${DAEMON_UID} ${htpasswd}
  chmod 0660 ${htpasswd}
fi

echo -e "\nPassEnv MARIADB_TLS_DISABLE_PEER_VERIFICATION\n" >> /usr/local/apache2/conf/httpd.conf
