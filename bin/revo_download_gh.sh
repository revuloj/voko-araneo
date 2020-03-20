
#!/bin/bash
#set -e
api=https://api.github.com
url=$(curl -s "${api}/repos/revuloj/revo-fonto/releases/latest" | \
    jq -r '.assets[] | select(.name | startswith("revohtml_") ) | .url' )
    
if [[ ! -z "$url" ]]; then    
    echo "downloading ${url}"
    echo "to: revohtml.zip"
    curl -L -H "Accept: application/octet-stream" -o revohtml.zip "${url}"
    unzip -qo revohtml.zip
    rm revohtml.zip
fi    
