#!/bin/bash

#Write to stdout and to a log file
LOGFILE=/tmp/rc.local.log
exec &> >(tee -a $LOGFILE)

#The hostname of your Home Assistant service
homeassistant_hostname="localhost"

#The port of your Home Assistant service
homeassistant_port=8123

#The mqtt broker hostname 
mqtt_broker_hostname="localhost"

#The username of your mqtt broker account
mqtt_broker_username="user1"

#The password of your mqtt broker account
mqtt_broker_password="password1"

#The mqtt broker service port
mqtt_broker_port=1883

#How often (in seconds) to push new Bluetti station metrics to Home Assistant (default: 30)
mqtt_scan_interval=30

#Bluetti station Bluetooth MAC addresses for discovery. Leave second MAC as zeroes if you're only using one.
station1_mac="00:00:00:00:00:00"
station1_description=""	#Example: AC200Max, AC300, etc.

station2_mac="00:00:00:00:00:00"
station2_description="" #Example: AC200Max, AC300, etc.

echo "Script started at $(date '+%Y-%m-%d %H:%M:%S')"

#Kill bluetti-mqtt if it is running
if [ $(ps -ef | grep bluetti-mqtt | wc -l) -gt 1 ]; then
        pkill bluetti-mqtt
fi

echo "Restarting Bluetooth service..."
/usr/bin/systemctl restart bluetooth

echo "Waiting for Bluetooth service to finish starting..."
/bin/sleep 5

echo "Discovering Bluetti stations via Bluetooth..."
discovery=$(timeout 10 /usr/local/bin/bluetti-discovery --scan)

station1_disc=$(echo $discovery | grep -q $station1_mac; echo $?)
station2_disc=$(echo $discovery | grep -q $station2_mac; echo $?)

station1_online=0
station2_online=0

echo "Done with discovery"

if [ $station1_disc -eq 0 ]; then
        echo "Station 1 ($station1_description) is online!"
        station1_online=1
fi
if [ $station2_disc -eq 0 ]; then
        echo "Station 2 ($station2_description) is online!"
        station2_online=1
fi

echo "Waiting for Home Assistant [$homeassistant_hostname:$homeassistant_port] to finish starting..."

i=0
while true; do
	i=$[$i+1]
	HA_port_test=$(timeout 2 bash -c "</dev/tcp/$homeassistant_hostname/$homeassistant_port" 2> /dev/null; echo $?)
	
	if [ $HA_port_test -eq 0 ]; then
		#We wait 20 sec after Home Assistant port responds to TCP test for its MQTT service to be able to receive the bluetti-mqtt device discovery message
		/bin/sleep 20
		break
	elif [ $i -lt 30 ]; then
		/bin/sleep 10
	else 
		echo "Exiting script as Home Assistant at $homeassistant_hostname : $homeassistant_port did not come up within 5 minutes"
		exit 1
	fi
done

echo "Starting Bluetti-mqtt..."

if [ $station1_online == 1 ] && [ $station2_online == 0 ]; then
        /usr/local/bin/bluetti-mqtt --broker $mqtt_broker_hostname --port $mqtt_broker_port --username $bluetti_mqtt_broker_username --password $bluetti_mqtt_broker_password --interval $mqtt_scan_interval $station1_mac &
elif [ $station2_online == 1 ] && [ $station1_online == 0 ]; then
        /usr/local/bin/bluetti-mqtt --broker $mqtt_broker_hostname --port $mqtt_broker_port --username $bluetti_mqtt_broker_username --password $bluetti_mqtt_broker_password --interval $mqtt_scan_interval $station2_mac &
elif [ $station2_online == 1 ] && [ $station1_online == 1 ]; then
        /usr/local/bin/bluetti-mqtt --broker $mqtt_broker_hostname --port $mqtt_broker_port --username $bluetti_mqtt_broker_username --password $bluetti_mqtt_broker_password --interval $mqtt_scan_interval $station1_mac $station2_mac &
fi

exit 0
