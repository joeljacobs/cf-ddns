#!/bin/sh
# modified by jfro from http://www.cnysupport.com/index.php/linode-dynamic-dns-ddns-update-script
# Uses curl to be compatible with machines that don't have wget by default
# modified by Ross Hosman for use with cloudflare.

# Use $1 to force a certain IP.

source credentials

IPSOURCE=$(curl -s http://www.google.com/search?q=my+ip)
CURRENT_IP=$(echo "$IPSOURCE"|sed -n 's/.*(Client IP address: \([^)]*\)).*$/\1/p')
#CURRENT_IP=`echo "$IPSOURCE"|egrep IP.*\:|sed 's/^.*\ \([0-9]*\.[0-9]*\.[0-9]*.[0-9]*\).*/\1/'`
WAN_IP=${1-$CURRENT_IP}
echo "WANIP IS $WAN_IP"

PERSISTENTFILE="/data/.wan_ip-cf.txt"


function domain_records() {
curl -k https://www.cloudflare.com/api_json.html \
  -d "tkn=$cfkey" \
  -d "email=$email" \
  -d "z=$zone" \
  -d 'a=rec_load_all' 2>/dev/null |jq "."
}

function record_id () {
domain_records|jq ".response.recs.objs[]|select(.display_name==\"$1\")|.rec_id" -r
}

if [ -f $PERSISTENTFILE ]; then
        OLD_WAN_IP=`cat $PERSISTENTFILE`
else
        echo "No file, need IP"
        OLD_WAN_IP="nonsense"
fi

if [ "$WAN_IP" = "$OLD_WAN_IP" ]; then
        echo "IP Unchanged"
else
        echo $WAN_IP > /data/.wan_ip-cf.txt
        echo "Updating DNS to $WAN_IP"
curl -k https://www.cloudflare.com/api_json.html \
-d "tkn=$cfkey" \
-d "email=$email" \
-d 'ttl=1' \
-d "z=$zone" \
-d 'a=rec_edit' \
-d "id=$(record_id $cfhost)" \
-d 'type=AAAA' \
-d "name=$cfhost" \
-d "content=$WAN_IP"
fi

