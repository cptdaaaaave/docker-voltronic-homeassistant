#!/bin/bash
#
# Simple script to delete sensor topics to allow recreation with Unique IDs
# Script has been tested with 2023.1.7 HA and DOES NOT delete historical sensor data
# DO NOT change the associated sensor name.

CONFIG_FILE='/etc/inverter/mqtt.json'

MQTT_SERVER=`cat $CONFIG_FILE | jq '.server' -r`
MQTT_PORT=`cat $CONFIG_FILE | jq '.port' -r`
MQTT_TOPIC=`cat $CONFIG_FILE | jq '.topic' -r`
MQTT_DEVICENAME=`cat $CONFIG_FILE | jq '.devicename' -r`
MQTT_USERNAME=`cat $CONFIG_FILE | jq '.username' -r`
MQTT_PASSWORD=`cat $CONFIG_FILE | jq '.password' -r`
MQTT_CLIENTID=`cat $CONFIG_FILE | jq '.clientid' -r`

deleteTopic () {
    mosquitto_pub \
        -h $MQTT_SERVER \
        -p $MQTT_PORT \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
        -i $MQTT_CLIENTID \
        -t "$MQTT_TOPIC/sensor/"$MQTT_DEVICENAME"_$1/config" \
        -m ""
}

for topic in "Inverter_mode" "AC_grid_voltage" "AC_grid_frequency" "AC_out_voltage" "AC_out_frequency" "PV_in_voltage" "PV_in_current" "PV_in_watts" "PV_in_watthour" "SCC_voltage" "Load_pct" "Load_watt" "Load_watthour" "Load_va" "Bus_voltage" "Heatsink_temperature" "Battery_capacity" "Battery_voltage" "Battery_charge_current" "Battery_discharge_current" "Load_status_on" "SCC_charge_on" "AC_charge_on" "Battery_recharge_voltage" "Battery_under_voltage" "Battery_bulk_voltage" "Battery_float_voltage" "Max_grid_charge_current" "Max_charge_current" "Out_source_priority" "Charger_source_priority" "Battery_redischarge_voltage" 
do
    deleteTopic $topic
done
