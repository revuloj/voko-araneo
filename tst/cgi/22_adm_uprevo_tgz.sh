#!/bin/bash

# trovu procezujon araneo
araneo_id=$(docker ps --filter name=araneujo_araneo -q)

if [[ -z ${araneo_id} ]]; then
    echo "La procezujo araneujo_araneo ne estas aktiva!"
    echo "Unu lanĉu Araneujon (revo-medioj/araneujo-s/bin/as-start)."
    exit 1;
fi

tempo=$(date +'%Y%m%d_%H%M%S')
tmp_dir=$(mktemp -d)
mkdir -p ${tmp_dir}/revo/xml
art=revo/xml/test333.xml
tgz=${tmp_dir}/revo-${tempo}.tgz

# preparu tgz-arĥivon por testi uprevo.pl
cat << '~~~~~' > ${tmp_dir}/${art}
<?xml version="1.0"?><!DOCTYPE vortaro SYSTEM "../dtd/vokoxml.dtd"><vortaro>
<art mrk="$Id: test333.xml,v 1.116 2021/06/22 19:02:35 revo Exp $">
<kap><ofc>*</ofc><rad>test333</rad></kap>
<drv mrk="test333.0"><kap><tld/></kap>
<snc><dif>Kvar minus unu. Matematika simbolo 3:<ekz><tld/> kaj sep faras dek dek
<fnt><bib>F</bib><lok>&FE; 12</lok></fnt>;</ekz>
</dif></snc></drv></art></vortaro>
~~~~~
tar -cvzf ${tgz} -C "$tmp_dir" ${art}

# ĉio en ordo?
echo ">>> ${tgz}"
tar -tvzf ${tgz} ${art}

# kopiu la arĥivon en Araneon
docker cp ${tgz} ${araneo_id}:/hp/af/ag/ri/www/alveno/
rm -rf ${tmp_dir}
