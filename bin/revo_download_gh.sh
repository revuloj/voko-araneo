
#!/bin/bash
#set -e

# vi povas ŝalti al fonto revo-fonto-testo donante ĝin kiel unuan argumenton!
revo_fonto=${1:-revo-fonto}

api=https://api.github.com
eldono=$( curl -s "${api}/repos/revuloj/${revo_fonto}/releases/latest" | jq -c '.assets[]' )

html_url=$( echo $eldono | jq -r 'select(.name|startswith("revohtml_")) | .url' )
art_url=$(  echo $eldono | jq -r 'select(.name|startswith("revoart_"))  | .url' )
hst_url=$(  echo $eldono | jq -r 'select(.name|startswith("revohst_"))  | .url' )

xml_url=https://github.com/revuloj/${revo_fonto}/archive/master.zip

if [[ ! -z "$html_url" ]]; then    
    echo "revohtml.zip <- ${html_url}"
    curl -L -H "Accept: application/octet-stream" -o revohtml.zip "${html_url}"
else
    echo "ERARO: Arĥivo revohtml_*.zip ne troviĝis en la lasta eldono!"
    exit 1
fi

if [[ ! -z "$art_url" ]]; then    
    echo "revoart.zip <- ${art_url}"
    curl -L -H "Accept: application/octet-stream" -o revoart.zip "${art_url}"
else
    echo "ERARO: Arĥivo revoart_*.zip ne troviĝis en la lasta eldono!"
    exit 1
fi

if [[ ! -z "$hst_url" ]]; then    
    echo "revohst.zip <- ${html_url}"
    curl -L -H "Accept: application/octet-stream" -o revohst.zip "${hst_url}"
else
    echo "ERARO: Arĥivo revohst_*.zip ne troviĝis en la lasta eldono!"
    exit 1
fi

echo "master.zip <- ${xml_url}"
curl -L -H "Accept: application/zip" -o master.zip "${xml_url}"

unzip -qo revohtml.zip && rm revohtml.zip
unzip -qo revoart.zip && rm revoart.zip
unzip -qo revohst.zip && rm revohst.zip

dirname=${revo_fonto}-master
unzip -qo master.zip \
  && mv ${dirname}/revo revo/xml \
  && mv ${dirname}/cfg revo/cfg \
  && mv ${dirname}/bld revo/bld \
  && rm -rf ${dirname} && rm master.zip
