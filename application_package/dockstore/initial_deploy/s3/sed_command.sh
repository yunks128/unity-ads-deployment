#!/usr/bin/env bash

newip=`ifconfig  | grep -Eo '([0-9]*\.){3}[0-9]*' |  grep -v ^172 | grep -v 255 | grep -v ^127 | xargs echo` 
sed -i "s/10.52.14.72/${newip}/" config/default.nginx_http.*
sed -i "s/  hostname:.*http.*/  hostname: uads-test-dockstore/" config/web.yml
sed -i "s/.*ES_DELETE.*//g" config/web.yml

openssl pkcs8 -topk8 -nocrypt -in ../github-key/dockstore-github-private-key.pem -out ../github-key/tmp
mv -f ../github-key/tmp ../github-key/dockstore-github-private-key.pem
 
