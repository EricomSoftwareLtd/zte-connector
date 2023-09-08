#!/bin/bash
arg1=${1}   #Tenant name
arg2=${2}   #Connector name
arg3=${3}   #Connector key
arg4=${4}   #API key [OPTIONAL]
arg5=${5}   #Tenant ID [OPTIONAL]

# Update the connector public IP if optional arguments are present.
if [ -n "$arg4" ];
then
#build auth JSON
printf "Authenticating...\n"
auth='{"tenantID": "'"$arg5"'", "key": "'"$arg4"'" }'
curl -s -c /tmp/cookies.txt -X POST -H "Content-Type: application/json" "https://ztadmin.ericomcloud.net/api/v1/auth" -d "$auth" -o /tmp/auth.json
jwt=$(grep -o '"JWT".*' /tmp/auth.json| cut -d: -f2 |cut -d, -f1 | cut -d ' ' -f 2|tr -d '"' )
cookie=$(grep -o 'route.*' /tmp/cookies.txt| awk '{$0=tolower($0);$1=$1}1' | cut -d ' ' -f 2 )

#Update the connector public IP
printf "Determining the public IP...\n"
public_ip=$(curl -s "https://ifconfig.me")
printf "Public IP: $public_ip\n"
printf "Updating the connector public IP on ZTEdge side...\n"
upd_json='{"public_ip": "'"$public_ip"'" }'
curl -s -X PATCH "https://ztadmin.ericomcloud.net/api/v1/ztna/connector/$arg2" -H "Content-Type: application/json" -H "Authorization: Bearer "$jwt"" -H "Cookie: route=$cookie" -d "$upd_json" --write-out '%{http_code}'
printf "Done\n"
sleep 5
fi

# Run the script in a connector mode.
/usr/local/bin/ztedge-client new $arg1 $arg2 --connector --password $arg3 --listen-port 51820 --health-check-port 51821
tail -f /dev/null
