#!/bin/bash

# tuj finu se unuopa komando fiaskas 
# - necesas por distingi sukcesan de malsukcesa testaro
set -e

docker_image="${1:-voko-araneo:latest}"

# lanĉi la test-procezujon
docker run -p 80 --name araneo-test --rm -d ${docker_image}

# atendi, ĝis ĝi ricevis retpordon
while ! docker port araneo-test
do
  echo "$(date) - atendante retpordon"
  sleep 1
done

DPORT=$(docker port araneo-test | head -n 1)
HPORT=${DPORT/#*-> }

echo "retpordo:" $HPORT
echo "Lanĉo de la servo daŭras iomete..."

# https://superuser.com/questions/272265/getting-curl-to-output-http-status-code
while ! curl -I "http://$HPORT/" 2> /dev/null
do
  echo "$(date) - atendante malfermon de TTT-servo"
  sleep 3
done

# Izolite ni ne povas testi dinamikajn retpaĝojn, ĉar la datumbazo mankas.
# Sed kiel fumtesto ni povas peti kelkajn tatikajn paĝojn por vidi, ĉu la
# baza funkcio sukcesas.

echo ""; echo "Petante indeks-paĝon..."
curl -fsI "http://$HPORT/"

echo ""; echo "Petante indeks-paĝon _plena..."
curl -fsI "http://$HPORT/revo/inx/_plena.html"

echo ""; echo "Petante Revo-piktogramon..."
curl -fsI "http://$HPORT/revo/smb/revo.png"

echo ""; echo "Petante fako-piktogramon ESP..."
curl -fsI "http://$HPORT/revo/smb/ELET.png"

echo ""; echo "Petante lingvo-liston..."
curl -fsI "http://$HPORT/revo/cfg/lingvoj.xml"

echo ""; echo "Petante fako-liston..."
curl -fsI "http://$HPORT/revo/cfg/fakoj.xml"

echo ""; echo "Petante indeks-paĝon kaj ekstraktante la nomon de CSS kaj JS-dosieroj..."
LINK=$(curl -fs "http://$HPORT/" | grep "<link")
echo "link: $LINK"
[[ $LINK =~ href=\"([^\"]*\.css)\" ]]
CSS="${BASH_REMATCH[1]}"
echo "css: $CSS"
[[ $LINK =~ href=\"([^\"]*\.js)\" ]]
JS="${BASH_REMATCH[1]}"
echo "js: $JS"

echo ""; echo "Petante JS-dosieron..."
curl -fsI "http://$HPORT/$JS"

echo ""; echo "Petante CSS-dosieron..."
curl -fsI "http://$HPORT/$CSS"

echo ""; echo "Forigi..."
docker kill araneo-test