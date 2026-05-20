#!/bin/bash

# preparo por testo 22_adm_uprevo.t (vokata el ĝi)

# trovu procezujon araneo
stack=araneujotesto
araneo_id=$(docker ps --filter name=${stack}_araneo -q)

if [[ -z ${araneo_id} ]]; then
    echo "La procezujo ${stack}_araneo ne estas aktiva!"
    echo "Unue lanĉu Araneujon (revo-medioj/araneujo-t/bin/as-start)."
    exit 1;
fi

tempo=$(date +'%Y%m%d_%H%M%S')
tmp_dir=$(mktemp -d)
mkdir -p ${tmp_dir}/revo/xml
art0=revo/xml/test000.xml # forigenda
art=revo/xml/test333.xml  # aldonenda
tgz=revo-${tempo}.tgz

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

# preparu forigliston
echo "$art0" > ${tmp_dir}/bv_forigu_tiujn.lst

# preparu tgz-arĥivon por testi uprevo.pl
tar -cvzf ${tmp_dir}/${tgz} -C "$tmp_dir" ${art} bv_forigu_tiujn.lst

# ĉio en ordo?
echo ">>> ${tgz}"
tar -tvzf ${tmp_dir}/${tgz}

# kopiu la arĥivon en Araneon
docker exec -u root ${araneo_id} rm -f /hp/af/ag/ri/www/$art
docker cp ${tmp_dir}/${art} ${araneo_id}:/hp/af/ag/ri/www/$art0
docker exec -u root ${araneo_id} chown daemon /hp/af/ag/ri/www/$art0
docker cp ${tmp_dir}/${tgz} ${araneo_id}:/hp/af/ag/ri/www/alveno/
docker exec -u root ${araneo_id} chown daemon /hp/af/ag/ri/www/alveno/${tgz}

rm -rf ${tmp_dir}
