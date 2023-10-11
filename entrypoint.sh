#!/bin/bash
arg1=${1}   #Tenant name
arg2=${2}   #Connector name
arg3=${3}   #Connector key
arg4=${4}   #API key [OPTIONAL]
arg5=${5}   #Tenant ID [OPTIONAL]

LOG_FILE=/var/log/ztedge.log
printf "$(date +%m-%d-%Y-%T) Container started \n" | tee ${LOG_FILE}
# Update the connector public IP if optional arguments are present.
update_ip () {
if [ -n "$arg4" ];
then
#build auth JSON
printf "$(date +%m-%d-%Y-%T) Authenticating...\n" | tee -a ${LOG_FILE}
auth='{"tenantID": "'"$arg5"'", "key": "'"$arg4"'" }'
curl -s -c /tmp/cookies.txt -X POST -H "Content-Type: application/json" "https://ztadmin.ericomcloud.net/api/v1/auth" -d "$auth" -o /tmp/auth.json
jwt=$(grep -o '"JWT".*' /tmp/auth.json| cut -d: -f2 |cut -d, -f1 | cut -d ' ' -f 2|tr -d '"' )
cookie=$(grep -o 'route.*' /tmp/cookies.txt| awk '{$0=tolower($0);$1=$1}1' | cut -d ' ' -f 2 )

#Update the connector public IP
printf "$(date +%m-%d-%Y-%T) Determining the public IP...\n" | tee -a ${LOG_FILE}
public_ip=$(curl -s "https://ifconfig.me")
printf "$(date +%m-%d-%Y-%T) Public IP: $public_ip\n" | tee -a ${LOG_FILE}
printf "$(date +%m-%d-%Y-%T) Updating the connector public IP on ZTEdge side...\n" | tee -a ${LOG_FILE}
upd_json='{"public_ip": "'"$public_ip"'" }'
curl -s -X PATCH "https://ztadmin.ericomcloud.net/api/v1/ztna/connector/$arg2" -H "Content-Type: application/json" -H "Authorization: Bearer "$jwt"" -H "Cookie: route=$cookie" -d "$upd_json" --write-out '%{http_code}'
printf "$(date +%m-%d-%Y-%T) Done\n" | tee -a ${LOG_FILE}
sleep 5
fi
}

# Run update_ip func
update_ip
# Run the script in a connector mode.
printf "$(date +%m-%d-%Y-%T) Starting the connector...\n" | tee -a ${LOG_FILE}
/usr/local/bin/ztedge-client new $arg1 $arg2 --connector --password $arg3 --listen-port 51820 --health-check-port 51821 &
while true;
do
sleep 60;
check_ip=$(curl -s "https://ifconfig.me")
    if [ $check_ip == $public_ip ];
    then
        printf "."
    else
        printf "\n $(date +%m-%d-%Y-%T) Connector public IP changed: $check_ip. Updating IP in ZTEdge now...\n" | tee -a ${LOG_FILE}
        update_ip
        /usr/local/bin/ztedge-client down
        sleep 5
        /usr/local/bin/ztedge-client up &
    fi
done
