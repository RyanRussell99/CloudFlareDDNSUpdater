# Cloud Flare DDNS Updater
Simple shell script using https://checkip.amazonaws.com to get your current public IP address and update your DDNS using the Cloudfare API. 

## How to use

1. Clone in system root directory
2. In the cloned repository create a file named cloudFlareEnv.txt
3. The first line should be the Authorization Token for your account and the second should be the Zone id you wish to update
4. Create a chron job to run periodically on your Linux server via crontab -e and add a new line (ex: * * * * * /bin/bash /CloudFlareDDNSUpdater/cloudFlareDDNSUpdater.sh >> /CloudFlareDDNSUpdater/cron.log)
