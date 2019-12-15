#!/bin/bash
set -x

DAEMON_UID=13731
CGI_PASSWD=$(cat /run/secrets/voko-araneo.cgi_password)
htpasswd=/etc/httpd/.htpasswd

if [ ! -e ${htpasswd} ]; then
  echo ${CGI_PASSWD} | htpasswd -i -c ${htpasswd} araneo

  chown ${DAEMON_UID} ${htpasswd}
  chmod 0660 ${htpasswd}
fi  