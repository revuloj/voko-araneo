#!/bin/bash
#set -e
curl -sO http://reta-vortaro.de/tgz/dosieroj.xml
    
# extract entries of the form: 
#  <file name="revobld_2019-04-14.zip" size="3.7 MB"/>
# (revoxml_ revohtml_ revobld_ revonov_)

for file in $(grep -o "\(revoxml_\|revohtml_\|revobld_\|revonov_\).*\.zip" dosieroj.xml)
do
    echo "curl -O http://reta-vortaro.de/tgz/${file}"
    curl -O http://reta-vortaro.de/tgz/${file}
done

unzip -q revo?ml*.zip
unzip -q revobld*.zip
for zip in $(ls revonov*.zip | sort)
do
    unzip -q -o ${zip}
done

rm *.zip dosieroj.xml


    