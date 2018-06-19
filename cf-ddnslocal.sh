#!/bin/bash -x
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# modified by jfro from http://www.cnysupport.com/index.php/linode-dynamic-dns-ddns-update-script
# Uses curl to be compatible with machines that don't have wget by default
# modified by Ross Hosman for use with cloudflare.

# Use $1 to force a certain IP.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #sets the directory of this executable

source $DIR/credentials

CURRENT_IP=$(ifconfig eth0 |grep inet\ |cut -d ":" -f 2|cut -d " " -f 1)
WAN_IP=${1-$CURRENT_IP}

#echo "$WAN_IP=$WAN_IP CURRENT_IP=$CURRENT_IP cfhost=$cfhost"


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

OLD_WAN_IP=$(/usr/bin/host -t A ${cfhost}.${zone}|cut -d " " -f 4)

if [ "$WAN_IP" = "$OLD_WAN_IP" ]; then
        echo "IP Unchanged ($WAN_IP = $OLD_WAN_IP)"
else
        #echo $WAN_IP > $HOME/.wan_ip-cf.txt
        echo "Updating DNS to $WAN_IP"
curl -k https://www.cloudflare.com/api_json.html \
-d "tkn=$cfkey" \
-d "email=$email" \
-d 'ttl=1' \
-d "z=$zone" \
-d 'a=rec_edit' \
-d "id=$(record_id $cfhost)" \
-d 'type=A' \
-d "name=$cfhost" \
-d "content=$WAN_IP"
fi