
#!/bin/bash
#set -e
api=https://api.github.com
eld=$( curl -s "${api}/repos/revuloj/revo-fonto/releases/latest" | jq -c '.assets[]' )

html_url=$( echo $eld | jq -r 'select(.name|startswith("revohtml_")) | .url' )
art_url=$(  echo $eld | jq -r 'select(.name|startswith("revoart_"))  | .url' )
hst_url=$(  echo $eld | jq -r 'select(.name|startswith("revohst_"))  | .url' )
    
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

unzip -qo revohtml.zip && rm revohtml.zip
unzip -qo revoart.zip && rm revoart.zip
unzip -qo revohst.zip && rm revohst.zip
