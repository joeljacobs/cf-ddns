#!/bin/sh
# modified by jfro from http://www.cnysupport.com/index.php/linode-dynamic-dns-ddns-update-script
# Uses curl to be compatible with machines that don't have wget by default
# modified by Ross Hosman for use with cloudflare.

# Use $1 to force a certain IP.

cfkey=
cfhost=<hostname>
email='<github email-address>'
zone='<zone>'
id=<record ID> #dns record ID

CURRENT_IP=`curl -s http://www.google.com/search?q=my+ip|egrep IP.*\:|sed 's/^.*\ \([0-9]*\.[0-9]*\.[0-9]*.[0-9]*\).*/\1/'`
WAN_IP=${1-$CURRENT_IP}
if [ -f $HOME/.wan_ip-cf.txt ]; then
        OLD_WAN_IP=`cat $HOME/.wan_ip-cf.txt`
else
        echo "No file, need IP"
        OLD_WAN_IP=""
fi

if [ "$WAN_IP" = "$OLD_WAN_IP" ]; then
        echo "IP Unchanged"
else
        echo $WAN_IP > $HOME/.wan_ip-cf.txt
        echo "Updating DNS to $WAN_IP"
curl -k https://www.cloudflare.com/api_json.html \
-d "tkn=$cfkey" \
-d "email=$email" \
-d 'ttl=1' \
-d "z=$zone" \
-d 'a=rec_edit' \
-d "id=$id" \
-d 'type=A' \
-d "name=$cfhost" \
-d "content=$WAN_IP"
fi
