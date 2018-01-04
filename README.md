# AppDynamics_IoT_Simulator

This script simulates the instrumentation of an IoT application using the AppDynamics IoT RestAPI. 
It sends IoT telemetries to AppDDynamics every minute. 

## The steps are: 
1. It checks to see if your AppKey exist and if it is enabled 
2. It validates the JSON request body format 
3. It sends temperature and humidity beacons to AppD, including network requests and errors from the sensors. 

The script runs every minute
Each run generates different values for temperature and humidity 

## To run the script:
1. Follow this [instruction](https://docs.appdynamics.com/display/PRO44/Set+Up+and+Access+IoT+Monitoring) to create an IoT application in your AppDynamics Controller
2. Copy your AppKey from step 1. 
3. Clone this repo
4. Make the script executable : chmod +x iot.sh
5. In your termainal, run:  ./iot.sh < appkey > for example ./iot.sh AB-CDE-FGH-IJK 
6. Give it about 3 to 5 minutes and check your controller 

