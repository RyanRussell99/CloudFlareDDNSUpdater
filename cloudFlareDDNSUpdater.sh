#!/bin/bash
PUBLIC_IP=$(curl "https://checkip.amazonaws.com")

line_number=1
while IFS= read -r line; do
  if [ $line_number == 1 ]; then
    AUTH_TOKEN=$line
  fi
  if [ $line_number == 2 ]; then
    ZONE_ID=$line
  fi
  ((line_number++))
done < "cloudFlareEnv.txt"

CLOUDFLARE_LIST_DNS=$( curl --request GET --url https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records   --header 'Content-Type: application/json' --header "Authorization: Bearer $AUTH_TOKEN")

RECORDS=$(echo $CLOUDFLARE_LIST_DNS | jq '.result | length' )

for (( i=0; i < RECORDS; ++i ))
do
    DNS_RECORD_ID=$(echo $CLOUDFLARE_LIST_DNS | jq ".result[$i].id")
    temp="${DNS_RECORD_ID%\"}"
    DNS_RECORD_ID="${temp#\"}"
    NAME=$(echo $CLOUDFLARE_LIST_DNS | jq ".result[$i].name")
    PROXIED=$(echo $CLOUDFLARE_LIST_DNS | jq ".result[$i].proxied")
    TTL=$(echo $CLOUDFLARE_LIST_DNS | jq ".result[$i].ttl")
    TYPE=$(echo $CLOUDFLARE_LIST_DNS | jq ".result[$i].type")
    SETTINGS=$(echo $CLOUDFLARE_LIST_DNS | jq ".result[$i].settings")
    TAGS=$(echo $CLOUDFLARE_LIST_DNS | jq ".result[$i].tags")
    ZONE_NAME=$(echo $CLOUDFLARE_LIST_DNS | jq ".result[$i].zone_name")
    
    NAME=${NAME%"$ZONE_NAME"}
    if [ "$NAME" == "" ]; then
        NAME='"@"'
    fi
    
    DATA='{"comment": "Domain verification record","name": '$NAME',"proxied": '$PROXIED',"settings": '$SETTINGS',"tags": '$TAGS',"ttl": '$TTL',"content": "'$PUBLIC_IP'","type": '$TYPE'}'

    CLOUDFLARE_RESP=$(curl -s -X PUT \
    --url https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $AUTH_TOKEN" \
    --data "$DATA")
    echo "$CLOUDFLARE_RESP"
done
