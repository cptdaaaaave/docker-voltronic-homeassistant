#!/bin/bash
#
# Simple script to register the MQTT topics when the container starts for the first time...

CONFIG_FILE='/etc/inverter/mqtt.json'

MQTT_SERVER=`cat $CONFIG_FILE | jq '.server' -r`
MQTT_PORT=`cat $CONFIG_FILE | jq '.port' -r`
MQTT_TOPIC=`cat $CONFIG_FILE | jq '.topic' -r`
MQTT_DEVICENAME=`cat $CONFIG_FILE | jq '.devicename' -r`
MQTT_USERNAME=`cat $CONFIG_FILE | jq '.username' -r`
MQTT_PASSWORD=`cat $CONFIG_FILE | jq '.password' -r`
MQTT_CLIENTID=`cat $CONFIG_FILE | jq '.clientid' -r`
MQTT_INVERTERNAME=`cat $CONFIG_FILE | jq '.invertername' -r`
MQTT_INVERTERMODEL=`cat $CONFIG_FILE | jq '.invertermodel' -r`
MQTT_INVERTERMANU=`cat $CONFIG_FILE | jq '.invertermanu' -r`

registerTopic () {
    mosquitto_pub \
        -h $MQTT_SERVER \
        -p $MQTT_PORT \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
        -i $MQTT_CLIENTID \
        -t "$MQTT_TOPIC/sensor/"$MQTT_DEVICENAME"_$1/config" \
        -m "{
            \"name\": \""$MQTT_DEVICENAME"_$1\",
            \"unit_of_measurement\": \"$2\",
            \"unique_id\": \"$(echo "$MQTT_CLIENTID_$1" | shasum -a 1 | cut -f 1 -d ' ')\",
            \"state_topic\": \"$MQTT_TOPIC/sensor/"$MQTT_DEVICENAME"/state\",
            \"icon\": \"mdi:$3\",
            \"value_template\": \"{{ value_json.$1 }}\",
            \"device\": {
                \"identifiers\": \"$MQTT_INVERTERNAME\",
                \"name\": \"$MQTT_INVERTERNAME\",
                \"model\": \"$MQTT_INVERTERMODEL\",
                \"manufacturer\": \"$MQTT_INVERTERMANU\" }
        }"
}

registerInverterRawCMD () {
    mosquitto_pub \
        -h $MQTT_SERVER \
        -p $MQTT_PORT \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
        -i $MQTT_CLIENTID \
        -t "$MQTT_TOPIC/sensor/$MQTT_DEVICENAME/config" \
        -m "{
            \"name\": \""$MQTT_DEVICENAME"\",
            \"object_id\":\""$MQTT_CLIENTID"\",
            \"state_topic\": \"$MQTT_TOPIC/sensor/$MQTT_DEVICENAME/state\"
        }"
}

registerTopic "Inverter_mode" "" "solar-power" # 1 = Power_On, 2 = Standby, 3 = Line, 4 = Battery, 5 = Fault, 6 = Power_Saving, 7 = Unknown
registerTopic "AC_grid_voltage" "V" "power-plug"
registerTopic "AC_grid_frequency" "Hz" "current-ac"
registerTopic "AC_out_voltage" "V" "power-plug"
registerTopic "AC_out_frequency" "Hz" "current-ac"
registerTopic "PV_in_voltage" "V" "solar-panel-large"
registerTopic "PV_in_current" "A" "solar-panel-large"
registerTopic "PV_in_watts" "W" "solar-panel-large"
registerTopic "PV_in_watthour" "Wh" "solar-panel-large"
registerTopic "SCC_voltage" "V" "current-dc"
registerTopic "Load_pct" "%" "brightness-percent"
registerTopic "Load_watt" "W" "chart-bell-curve"
registerTopic "Load_watthour" "Wh" "chart-bell-curve"
registerTopic "Load_va" "VA" "chart-bell-curve"
registerTopic "Bus_voltage" "V" "details"
registerTopic "Heatsink_temperature" "" "details"
registerTopic "Battery_capacity" "%" "battery-outline"
registerTopic "Battery_voltage" "V" "battery-outline"
registerTopic "Battery_charge_current" "A" "current-dc"
registerTopic "Battery_discharge_current" "A" "current-dc"
registerTopic "Load_status_on" "" "power"
registerTopic "SCC_charge_on" "" "power"
registerTopic "AC_charge_on" "" "power"
registerTopic "Battery_recharge_voltage" "V" "current-dc"
registerTopic "Battery_under_voltage" "V" "current-dc"
registerTopic "Battery_bulk_voltage" "V" "current-dc"
registerTopic "Battery_float_voltage" "V" "current-dc"
registerTopic "Max_grid_charge_current" "A" "current-ac"
registerTopic "Max_charge_current" "A" "current-ac"
registerTopic "Out_source_priority" "" "grid"
registerTopic "Charger_source_priority" "" "solar-power"
registerTopic "Battery_redischarge_voltage" "V" "battery-negative"

# Add in a separate topic so we can send raw commands from assistant back to the inverter via MQTT (such as changing power modes etc)...
registerInverterRawCMD
