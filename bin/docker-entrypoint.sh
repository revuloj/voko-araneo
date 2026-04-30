#!/bin/bash
#set -e
#set -x

setup_cgi_user.sh

# PLIBONIGU: 
# 1. ebligu konservadon kaj aktualigadon de la datumbazo, t.e.
#    praplenigu ĝin nur se ĝi ankoraŭ ne ekzistas / estas ankoraŭ malplena
# 2. antaŭ prapelnigi ĝin, testu unue ĉu la datumbazo estas jam aktiva
#    se ne, atendu iom kaj nur tiam plenigu ĝin!
(xml-json-db.pl; viki_listo.pl)&

exec "$@"