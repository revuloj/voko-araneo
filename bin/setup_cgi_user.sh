#!/bin/bash
set -x

DAEMON_UID=13731
#CGI_PASSWD=$(cat /run/secrets/voko-araneo.cgi_password)
htpasswd=/usr/local/apache2/conf/.htpasswd

if [ ! -e ${htpasswd} ]; then
  cat /run/secrets/voko-araneo.cgi_password | htpasswd -i -c ${htpasswd} araneo

  chown ${DAEMON_UID} ${htpasswd}
  chmod 0660 ${htpasswd}
fi  