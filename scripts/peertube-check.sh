#!/bin/bash

while :
do

USERNAME=$PTUSERNAME
PASSWORD=$PTPASSWORD
discord_url=$DISCORD
SERVER=$PTSERVER
INSTANCE=$AWSINSTANCE
PAUSE=$RUNEVERY


API_PATH_PT="https://$SERVER/api/v1"

## AUTH
client_id_pt=$(curl -s "${API_PATH_PT}/oauth-clients/local" | jq -r ".client_id")
client_secret_pt=$(curl -s "${API_PATH_PT}/oauth-clients/local" | jq -r ".client_secret")
token_pt=$(curl -s "${API_PATH_PT}/users/token" \
  --data client_id="${client_id_pt}" \
  --data client_secret="${client_secret_pt}" \
  --data grant_type=password \
  --data response_type=code \
  --data username="${USERNAME}" \
  --data password="${PASSWORD}" \
  | jq -r ".access_token")

## Get Count
countJSON=$(curl -k "${API_PATH_PT}/runners/jobs?stateOneOf=2&stateOneOf=1&stateOneOf=1&count=100" \
  -H "Authorization: Bearer ${token_pt}") 

count_pt=$(jq -r '.total' <<< $countJSON)

echo "Pending Peertube Remote Jobs $count_pt"

if [[ $count_pt -gt 0 ]]
then
  level=1
else
  level=0
fi
echo "Level is $level"
echo "Last Level $lastlevelvar"

generate_post_data() {
  cat <<EOF
{
  "content": "Message: Runner Count Changed from $lastlevelvar to $level",
  "embeds": [{
    "title": "URL",
    "description": "Runner Count Changed from $lastlevelvar to $level",
    "color": "45973"
  }]
}
EOF
}

if [[ $level -eq $lastlevelvar ]]
then
  echo "No Level Change Needed"
elif [[ ($level -eq 1)  ]]
then
  aws ec2 start-instances --instance-ids $INSTANCE
  curl -H "Content-Type: application/json" -X POST -d "$(generate_post_data)" $discord_url
else
#then
  aws ec2 stop-instances --instance-ids $INSTANCE
  curl -H "Content-Type: application/json" -X POST -d "$(generate_post_data)" $discord_url
fi

lastlevel=$level

echo "--------------------------"

startTime=$(date --date="+$sleepTime seconds" '+%T')
echo "Sleeping for $sleepTime - $startTime"
sleep $sleepTime
echo "Pause Done"

done