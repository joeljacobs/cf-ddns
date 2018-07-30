#!/usr/bin/env bash
# modified by jfro from http://www.cnysupport.com/index.php/linode-dynamic-dns-ddns-update-script
# Uses curl to be compatible with machines that don't have wget by default
# modified by Ross Hosman for use with cloudflare.

# Use $1 to force a certain IP.
V4_URL='https://api.cloudflare.com/client/v4'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #sets the directory of this executable
source $DIR/credentials

INTERFACE=${2-"eth0"} #If using local IP, need to specify if not eth0

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


function domainid() {
curl -X GET $V4_URL'/zones' \
  -H 'X-Auth-Email: '$email \
  -H 'X-Auth-Key: '$cfkey \
  -H 'Content-Type: application/json' 2>/dev/null |jq "."|\
jq ".result[]|select(.name==\"$zone\")|.id" -r
}

function domain_records() {
curl -X GET $V4_URL"/zones/$(domainid)/dns_records" \
  -H 'X-Auth-Email: '$email \
  -H 'X-Auth-Key: '$cfkey \
  -H 'Content-Type: application/json' 2>/dev/null |jq "."
}

function record_id () {
domain_records|jq ".result[]|select(.name==\"$1.$zone\")|.id" -r
}

OLD_WAN_IP=$(host -t $TYPE ${cfhost}.${zone}|cut -d " " -f 4)

if [ "$WAN_IP" = "$OLD_WAN_IP" ]; then
        echo "IP Unchanged ($WAN_IP = $OLD_WAN_IP)" >/dev/null #commented out with /dev/null becasue of "if"
else
        echo "Updating DNS to $WAN_IP"
function generate_post_data(){
cat <<EOF
{
        "type": "$TYPE",
        "name": "${cfhost}.${zone}",
        "content": "$WAN_IP",
        "proxied": false
    }
EOF
}
curl -X PUT $V4_URL"/zones/$(domainid)/dns_records/$(record_id $cfhost)" \
    -H 'X-Auth-Email: '$email \
    -H 'X-Auth-Key: '$cfkey \
    -H 'Content-Type: application/json' \
    --data "$(generate_post_data)"
fi
