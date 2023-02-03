#!/usr/bin/env bash

newip=`ifconfig  | grep -Eo '([0-9]*\.){3}[0-9]*' |  grep -v ^172 | grep -v 255 | grep -v ^127 | xargs echo` 
sed -i "s/10.52.14.72/${newip}/" config/default.nginx_http.*
sed -i "s/  hostname:.*/  hostname: uads-test-dockstore/" config/web.yml




