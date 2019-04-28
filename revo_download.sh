#!/bin/bash
#set -e
revo=http://reta-vortaro.de
curl -sO ${revo}/tgz/dosieroj.xml
    
# extract entries of the form: 
#  <file name="revobld_2019-04-14.zip" size="3.7 MB"/>
# (revoxml_ revohtml_ revobld_ revonov_)

for file in $(grep -o "\(revoxml_\|revohtml_\|revobld_\|revonov_\).*\.zip" dosieroj.xml)
do
    echo "curl -O ${revo}/tgz/${file}"
    curl -O ${revo}/tgz/${file}
done

unzip -qo revohtml*.zip
unzip -qo revoxml*.zip
unzip -qo revobld*.zip
for zip in $(ls revonov*.zip | sort)
do
    unzip -quo ${zip}
done

rm *.zip dosieroj.xml

cd revo 

for f in index.html sercho.html titolo.html revo.jpg revo.ico
do
    echo "curl -sO ${revo}/revo/${f}"
    curl -sO ${revo}/revo/${f}
done