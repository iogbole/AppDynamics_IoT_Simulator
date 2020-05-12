#!/bin/bash

#API DOC: https://docs.appdynamics.com/javadocs/iot-rest-api/4.4/latest/ 


#This script simulates the instrumentation of an IoT Application using the AppDynamics IoT Rest APIs 
# The steps are: 
#1. It checks to see if your AppKey exist and if it is enabled 
#2. It validates the JSON request body  
#3. It sends IoT  telemetries i.e temp and humidity to AppD, including network requests and sensor errors. 
# The script runs every minute
#4. Each run generate different values for temperature and humidity 

#to run the script 

# ./iot.sh AB-CDE-FGH-IJK

# use https://<your-hostname>:<port>/eumcollector/iot/v1' for onpremise eum 
#eum_host="https://iot-col.eum-appdynamics.com/eumcollector/iot/v1"

eum_host="http://ec2-54-68-249-239.us-west-2.compute.amazonaws.com:7001/eumcollector/iot/v1"

app_key="$1"

beacon_template_file="testBeacon.json"

#validate if app_key is defined 
if [ -z "$app_key" ]
then
      echo "AppKey is not defined. The correct syntax to run this script is: ./iot.sh <app_key>  ". 
      sleep 3s 
      exit 0
else
      echo "Using AppKey: $app_key"
      sleep 1s
fi

#validate presence of JSON request body 
if [ ! -f "$beacon_template_file" ]
then
    echo " $beacon_template_file does not exist. Please define a template. Refer to https://docs.appdynamics.com/display/PRO44/Instrument+Applications+with+the+IoT+REST+APIs"
    echo "Exiting.."
    sleep 3s
    exit 0
else
  echo "Using $beacon_template_file as JSON body request template"
  sleep 1s
fi

function sensorIDs {
array[0]="DESKTOP-01"
array[1]="DESKTOP-02"
array[2]="DESKTOP-03"
array[3]="DESKTOP-04"
size=${#array[@]}
index=$(($RANDOM % $size))
echo ${array[$index]}
}

function Users {
array[0]="Paul Alan"
array[1]="Luke Lucas"
array[2]="John Doe"
array[3]="I DDOKS"
size=${#array[@]}
index=$(($RANDOM % $size))
echo ${array[$index]}
}

function send_telemetry {
    time_stamp=$(($(date +'%s * 1000 + %-N / 1000000')))
    echo "time in milliseconds $time_stamp"
    CPU=${RANDOM:1:2}
    Memory=${RANDOM:1:2}
    Disk=${RANDOM:1:2}
    name_attr=${RANDOM:0:1}
    device_id=$(sensorIDs)
    user_names=$(Users)
    echo "DeviceID $device_id"
    new_beacon=$(cat $beacon_template_file | sed 's/"timestamp": 1571431290706/"timestamp": '"$time_stamp"'/g; s/"CPU": 1/"CPU": '"$CPU"'/g ; s/"Memory": 1/"Memory": '"$Memory"'/g; s/"Disk": 1/"Disk": '"$Disk"'/g ; s/"deviceId": "io-75"/"deviceId": "'"$device_id"'"/g; s/"deviceName":"WeOne"/"deviceName": "'"$device_id - $user_names "'"/g; s/"User": "Paul Alan"/"User": "'"$user_names"'"/g')
    echo $new_beacon  > new.json
    #new_validation=$(curl -s -o -X POST -d "$new_beacon" /dev/null -w '%{http_code}' $eum_host/application/$app_key/validate-beacons)
    #echo $new_validation
    SEND_BEACON=$(curl -s -o -X POST -d "$new_beacon" /dev/null -w '%{http_code} %{size_request} %{size_upload}' $eum_host/application/$app_key/beacons)
    if [ "$SEND_BEACON" -eq 202 ]; then
    echo "Successfully sent telemetry to AppDynamics EUM Collector. Check your controller"
       echo "Press 'CTRL + C' to stop execution, otherwise it's going to send telemetry every minute."
  else
  	echo "Failed to send, http code : $SEND_BEACON "
  	exit 1
  fi 
}

 send_telemetry

function validate_beacon {
  response_code=$(curl -s -o -X POST -d "@$1" /dev/null -w '%{http_code}' $eum_host/application/$app_key/validate-beacons) 
  echo "$response_code"
}

#check if AppKey is enabled 
 is_app_key_enabled=$(
    curl $eum_host/application/$app_key/enabled \
        --write-out %{http_code} %{size_request} %{size_upload} \
        --silent \
        --output /dev/null \
    )

  if [ "$is_app_key_enabled" -ne 200 ]; then
    echo "AppKey isn't enabled, please double check that $app_key is correct \n HTTP STATUS CODE: $is_app_key_enabled  "
    exit 1
  else
    echo "AppKey is enabled, Please wait whilst we validate the beacon template"
    sleep 2s 
    #check validity of JSON request body 
    beacon_validation_response=$(validate_beacon $beacon_template_file)
  if [[ "$beacon_validation_response" != *"200" ]]; then
    echo "Beacon template isn't valid. HTTP STATUS CODE: $beacon_validation_response "
    exit 1
  else
    echo "JSON template is valid. Sending the following data to $eum_host/application/$app_key/validate-beacons"
    sleep 1s
     while :; do send_telemetry; sleep 60s; done
  fi
  fi



