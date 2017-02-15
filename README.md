#cf-ddns.sh
A shell script to update Cloudflare with your current public IP address

This script will check your current Public IP address using a Google query. It will then check a local file to see if it has changed. If the IP has changed, it will update the file, then push the new IP to Cloudflare.

This is intended to be used with cron or some other scheduler.

Requires curl.

You will need to create a file in the same directory named "credentials" with the following information:
+ Your Cloudflare Key
+ Your CloudFlare email address
+ Your CloudFlare Zone
+ The host record name you want to change

A sample credentials file has been included.

You can use my cloudflare-shell tool to manually view and edit your Cloudflare files from the command-line: https://github.com/joeljacobs/cloudflare-shell


Note: The hidden file that records your latest public IP address will be saved in $HOME/.wan_ip-cf.txt
