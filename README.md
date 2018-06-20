# cf-ddns.sh
A shell script to update Cloudflare with your current public IP address. It supports IPv4, IPv6 and Private addresses. 

This script will check your current Public or Local IP address using a Google query. It will then do a dns query to see if there's a change. If the IP has changed, it will push the new IP to Cloudflare.

This is intended to be used with cron or some other scheduler.

Requires curl. 

usage: `<path>/cf.ddns.sh <4|6|L> <network interface>`

  You can chose IPv4 (4), IPv6 (6), or your local Private IP (L). If you choose L, you should specify the network interface (i.e.: eth0)

You should put a PATH= expression before the binary for cron to work properly.

CRON example:

```*/10 * * * * PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /root/cf-ddns/cf-ddns.sh 4 2>&1 |logger -t cf-ddn```

You will need to create a file in the same directory named "credentials" with the following information:
+ Your Cloudflare Key
+ Your CloudFlare email address
+ Your CloudFlare Zone
+ The host record name you want to change

A sample credentials file has been included.

You can use my cloudflare-shell tool to manually view and edit your Cloudflare files from the command-line: https://github.com/joeljacobs/cloudflare-shell
