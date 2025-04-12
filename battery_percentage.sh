#!/bin/bash
# Адрес mqtt брокера и учетные данные
ip=192.168.0.201
usr="mqtt"
pass="mqtt"

# Опреление процента заряда батареи
battery_percentage=$(termux-battery-status | gawk 'BEGIN {RS=",";FS=":"} /percentage/ { gsub(",", ""); print $2 }')
echo "Процент заряда батареи: $battery_percentage"

# Отправка данных брокеру
echo " "
mosquitto_pub -h $ip -t "192.168.0.11/battery_percentage" -m $battery_percentage -u $usr -P $pass
echo "Данные отправлены брокеру в "$date
