#cf-ddns.sh
A shell script to update Cloudflare with your current public IP address

This script will check your current Public IP address using a Google query. It will then check a local file to see if it has changed. If the IP has changed, it will update the file, then push the new IP to Cloudflare.

This is intended to be used with cron or some other scheduler.

Requires curl.

You will need to provide the following:
+ Your Cloudflare Key
+ The host record name you want to change
+ Your CloudFlare email address
+ Your CloudFlare Zone
+ The host record ID

To obtain your record ID (among other things,) you can use my CloudFlare Shell script: https://github.com/joeljacobs/cloudflare-shell

The hidden file that records your latest public IP address will be saved in $HOME/.wan_ip-cf.txt
