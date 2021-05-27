#!/bin/bash

# uzu eligon de checkversio.pl por krei dosierliston, ekz. por forigi ilin per komando

usr=$1

#sekc='hst-xml'
curl -u ${usr} https://www.reta-vortaro.de/cgi-bin/admin/checkversioj.pl \
    | jq -j '."hst-xml" | map(.+".html") | join(" ")'
