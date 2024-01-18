#!/bin/bash
arg1=${1}   #Tenant name
arg2=${2}   #Connector name
arg3=${3}   #Connector key
arg4=${4}   #API key [OPTIONAL]
arg5=${5}   #Tenant ID [OPTIONAL]

LOG_FILE=/var/log/ztedge.log

# Start the script
printf "$(date +%m-%d-%Y-%T) Container started \n" |& tee ${LOG_FILE}
# Check external IP routine
check_ext_ip () {
    ext_ip=$(curl -s "https://ifconfig.me")
    echo $ext_ip
}
check_ip () {
    check_ext_ip
    while [ -z $ext_ip];
        do
            printf "$(date +%m-%d-%Y-%T) External IP is NULL...Retrying in 10 seconds\n" |& tee -a ${LOG_FILE}
            sleep 10
            check_ext_ip
        done
    printf "$(date +%m-%d-%Y-%T) External IP is $ext_ip\n" |& tee -a ${LOG_FILE}
    sleep 5
}
# Update the connector public IP if optional arguments are present.
update_ip () {
    if [ -n "$arg4" ];
        then
            #build auth JSON
            printf "$(date +%m-%d-%Y-%T) Authenticating...\n" |& tee -a ${LOG_FILE}
            auth='{"tenantID": "'"$arg5"'", "key": "'"$arg4"'" }'
            curl -s -c /tmp/cookies.txt -X POST -H "Content-Type: application/json" "https://cloud-demo-ztadmin.ericomcloud.net/api/v1/auth" -d "$auth" -o /tmp/auth.json
            jwt=$(grep -o '"JWT".*' /tmp/auth.json| cut -d: -f2 |cut -d, -f1 | cut -d ' ' -f 2|tr -d '"' )
            cookie=$(grep -o 'route.*' /tmp/cookies.txt| awk '{$0=tolower($0);$1=$1}1' | cut -d ' ' -f 2 )

            #Update the connector public IP
            printf "$(date +%m-%d-%Y-%T) Determining the public IP...\n" |& tee -a ${LOG_FILE}
            check_ip
            public_ip=$ext_ip
            printf "$(date +%m-%d-%Y-%T) Updating the connector public IP on ZTEdge side...\n" |& tee -a ${LOG_FILE}
            upd_json='{"public_ip": "'"$public_ip"'" }'
            curl -s -X PATCH "https://cloud-demo-ztadmin.ericomcloud.net/api/v1/ztna/connector/$arg2" -H "Content-Type: application/json" -H "Authorization: Bearer "$jwt"" -H "Cookie: route=$cookie" -d "$upd_json" --write-out '%{http_code}'
            printf "$(date +%m-%d-%Y-%T) Done\n" |& tee -a ${LOG_FILE}
            sleep 5
    fi
}

# Run update_ip func
update_ip
# Run the script in a connector mode.
printf "$(date +%m-%d-%Y-%T) Starting the connector...\n" |& tee -a ${LOG_FILE}
/usr/local/bin/ztedge-client new $arg1 $arg2 --connector --password $arg3 --listen-port 51820 --health-check-port 51821 &
# Check the status of the connector.
sleep 10;
status="$(/usr/local/bin/ztedge-client status)"
if [[ $status =~ "Tunnel is not active" ]]; then
    printf "$(date +%m-%d-%Y-%T) Config exists. Starting the connector...\n" |& tee -a ${LOG_FILE}
    /usr/local/bin/ztedge-client up
else
    printf "$(date +%m-%d-%Y-%T) $status\n" |& tee -a ${LOG_FILE}
fi
while true;
    do
    sleep 60;
    check_ip=$(check_ext_ip)
        if [ $check_ip == $public_ip ];
        then
            printf "."
        else
            if [ -z $check_ip ];
                then
                    printf "$(date +%m-%d-%Y-%T) Unable to determine external IP!\n" |& tee -a ${LOG_FILE}
                else
                    printf "$(date +%m-%d-%Y-%T) Connector public IP changed: $check_ip. Updating IP in ZTEdge now...\n" |& tee -a ${LOG_FILE}
            fi
            update_ip
            /usr/local/bin/ztedge-client down
            sleep 5
            /usr/local/bin/ztedge-client up &
        fi
    done
