#!/bin/bash

prove tst/cgi/[01]*.t

if ! prove -v tst/cgi/20_nombroj.t; then
    echo "AVERTO: testo 20_nombroj.t ne sukcesas, eble la datumbazo ankoraŭ ne tute pleniĝis!"
    echo "Do ni ne plenumas la ceterajn testojn. Reprovu poste!"
    exit 1
fi

# prove tst/cgi/2[01]*.t
#
# if [[ -z $CGI_USER || -z $CGI_PWD ]]; then
#     echo "Vi devas doni \$CGI_USER kaj \$CGI_PWD por testoj 22_adm*.t"
#     echo "Ni do ne plenumas tiujn testojn nun!"
#     exit 0
# fi
#
# prove tst/cgi/22*.t

prove tst/cgi/2*.t
