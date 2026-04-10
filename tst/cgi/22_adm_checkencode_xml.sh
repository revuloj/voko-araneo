#!/bin/bash

# preparo por testo 22_adm_checkencode.t (vokata el ĝi)

# trovu procezujon araneo
araneo_id=$(docker ps --filter name=araneujo_araneo -q)

if [[ -z ${araneo_id} ]]; then
    echo "La procezujo araneujo_araneo ne estas aktiva!"
    echo "Unu lanĉu Araneujon (revo-medioj/araneujo-s/bin/as-start)."
    exit 1;
fi

tmp_dir=$(mktemp -d)
mkdir -p ${tmp_dir}/revo/xml
art=revo/xml/testccc.xml  # aldonenda

# preparu XML-dosierojn por testi uprevo.pl
cat << '~~~~~' > ${tmp_dir}/${art}
<?xml version="1.0"?><!DOCTYPE vortaro SYSTEM "../dtd/vokoxml.dtd"><vortaro>
<art mrk="$Id: test333.xml,v 1.116 2021/06/22 19:02:35 revo Exp $">
<kap><ofc>*</ofc><rad>test333</rad></kap>
<drv mrk="test333.0"><kap><tld/></kap>
<snc><dif>Kvar minus unu. Matematika simbolo 3:<ekz><tld/> kaj sep faras dek dek
<fnt><bib>F</bib><lok>&FE; 12</lok></fnt>;</ekz>
</dif></snc></drv></art></vortaro>
~~~~~

# kopiu la artikolon en Araneon
echo START
docker cp ${tmp_dir}/${art} ${araneo_id}:/hp/af/ag/ri/www/$art
echo END
rm -rf ${tmp_dir}
