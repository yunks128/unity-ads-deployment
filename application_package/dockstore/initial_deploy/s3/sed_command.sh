#!/usr/bin/env bash

newip=`ip a s eth0 | grep -Eo 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'  | cut -d ' ' -f 2`
sed -i "s/10.52.14.72/${newip}/" config/default.nginx_http.*
sed -i "s/  hostname:.*http.*/  hostname: uads-test-dockstore/" config/web.yml
sed -i "s/.*ES_DELETE.*//g" config/web.yml

openssl pkcs8 -topk8 -nocrypt -in ../github-key/dockstore-github-private-key.pem -out ../github-key/tmp
mv -f ../github-key/tmp ../github-key/dockstore-github-private-key.pem

