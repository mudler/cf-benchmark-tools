#!/bin/bash
set -e

url=$1
iterations=${TEST_ITERATIONS:-1200}
sleep=${TEST_SLEEP:-1}

echo "realtime,total-time,connection-time,starttransfer-time"
echo "#header: curl $url"
echo "#footer: sleep $sleep - iterations $iterations"

for (( c=1; c<=$iterations; c++ )); do
    curl \
        -w "$(date +'%T'),%{time_total},%{time_connect},%{time_starttransfer}\n" \
        -s -o /dev/null "$url";
    sleep $sleep
done
