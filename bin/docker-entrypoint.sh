#!/bin/bash
#set -e
#set -x

setup_cgi_user.sh

# PLIBONIGU: testu unue ĉu la datumbazo estas jam aktiva
# se ne atendu iom kaj nur tiam plenigu ĝin!
xml-json-db.pl

exec "$@"