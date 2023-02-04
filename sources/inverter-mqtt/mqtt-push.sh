#!/bin/bash

### MISC
### Inverter Mode
### 1 = Power_On, 2 = Standby, 3 = Line, 4 = Battery, 5 = Fault, 6 = Power_Saving, 7 = Unknown
CONFIG_FILE='/etc/inverter/mqtt.jsonn'

INFLUX_ENABLED=`cat $CONFIG_FILE | jq '.influx.enabled' -r`

pushMQTTData () {
    MQTT_SERVER=`cat $CONFIG_FILE | jq '.server' -r`
    MQTT_PORT=`cat $CONFIG_FILE | jq '.port' -r`
    MQTT_TOPIC=`cat $CONFIG_FILE | jq '.topic' -r`
    MQTT_DEVICENAME=`cat $CONFIG_FILE | jq '.devicename' -r`
    MQTT_USERNAME=`cat $CONFIG_FILE | jq '.username' -r`
    MQTT_PASSWORD=`cat $CONFIG_FILE | jq '.password' -r`
    MQTT_CLIENTID=`cat $CONFIG_FILE | jq '.clientid' -r`

    mosquitto_pub \
        -h $MQTT_SERVER \
        -p $MQTT_PORT \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
        -i $MQTT_CLIENTID \
        -t "$MQTT_TOPIC/sensor/"$MQTT_DEVICENAME"/state" \
        -m "$1"
    
    
    if [[ $INFLUX_ENABLED == "true" ]] ; then
        pushInfluxData $1 $2
    fi
}

pushInfluxData () {
    INFLUX_HOST=`cat $CONFIG_FILE | jq '.influx.host' -r`
    INFLUX_USERNAME=`cat $CONFIG_FILE | jq '.influx.username' -r`
    INFLUX_PASSWORD=`cat $CONFIG_FILE | jq '.influx.password' -r`
    INFLUX_DEVICE=`cat $CONFIG_FILE | jq '.influx.device' -r`
    INFLUX_PREFIX=`cat $CONFIG_FILE | jq '.influx.prefix' -r`
    INFLUX_DATABASE=`cat $CONFIG_FILE | jq '.influx.database' -r`
    INFLUX_MEASUREMENT_NAME=`cat $CONFIG_FILE | jq '.influx.namingMap.'$1'' -r`
    
    curl -i -XPOST "$INFLUX_HOST/write?db=$INFLUX_DATABASE&precision=s" -u "$INFLUX_USERNAME:$INFLUX_PASSWORD" --data-binary "$INFLUX_PREFIX,device=$INFLUX_DEVICE $INFLUX_MEASUREMENT_NAME=$2"
}

INVERTER_DATA=`timeout 10 /opt/inverter-cli/bin/inverter_poller -1`

#####################################################################################

pushMQTTData "$INVERTER_DATA"

exit 0