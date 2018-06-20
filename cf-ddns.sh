#!/usr/bin/env bash
# modified by jfro from http://www.cnysupport.com/index.php/linode-dynamic-dns-ddns-update-script
# Uses curl to be compatible with machines that don't have wget by default
# modified by Ross Hosman for use with cloudflare.

# Use $1 to force a certain IP.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #sets the directory of this executable

source $DIR/credentials

IPSOURCE=$(curl -s http://www.google.com/search?q=my+ip)
CURRENT_IPV6=$(echo "$IPSOURCE"|sed -n 's/.*(Client IP address: \([^)]*\)).*$/\1/p')
CURRENT_IPV4=$(echo "$IPSOURCE"|egrep IP.*\:|sed 's/^.*\ \([0-9]*\.[0-9]*\.[0-9]*.[0-9]*\).*/\1/')
CURRENT_IPLOCAL=$(ifconfig $INTERFACE |grep inet\ |cut -d ":" -f 2|cut -d " " -f 1)

case $1 in
	6 )	TYPE="AAAA"
		WAN_IP=$CURRENT_IPV6 ;;
	4 )  	TYPE="A"
		WAN_IP=$CURRENT_IPV4 ;;
	L )	TYPE="A"
		WAN_IP=$CURRENT_IPLOCAL ;;
	* )	TYPE="A"
		WAN_IP=${1-$CURRENT_IPV4} ;;
esac

#echo "WAN_IP=$WAN_IP CURRENT_IPV6=$CURRENT_IPV6 CURRENT_IPV4=$CURRENT_IPV4 CURRENT_IPLOCAL=$CURRENT_IPLOCAL cfhost=$cfhost"


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

OLD_WAN_IP=$(host -t $TYPE ${cfhost}.${zone}|cut -d " " -f 4)

if [ "$WAN_IP" = "$OLD_WAN_IP" ]; then
        echo "IP Unchanged ($WAN_IP = $OLD_WAN_IP)" >/dev/null #commented out with /dev/null becasue of "if"
else
        echo "Updating DNS to $WAN_IP"
curl -k https://www.cloudflare.com/api_json.html \
-d "tkn=$cfkey" \
-d "email=$email" \
-d 'ttl=1' \
-d "z=$zone" \
-d 'a=rec_edit' \
-d "id=$(record_id $cfhost)" \
-d "type=$TYPE" \
-d "name=$cfhost" \
-d "content=$WAN_IP"
fi
