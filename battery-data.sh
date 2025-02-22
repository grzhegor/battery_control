
#!/bin/sh
IS_STARTS_FROM_TERMUX=1
CHECK_BATTERY_STATUS_PERIOD=30 #Секунды

if [ $IS_STARTS_FROM_TERMUX -eq 1 ]
then
	#Получаем данные о состоянии батареии, если запускаем из Termux
	batteryData=$(echo $(termux-battery-status) | awk -v CHECK_BATTERY_STATUS_PERIOD=$CHECK_BATTERY_STATUS_PERIOD 'END { gsub("}", ", \"checkPeriod\": "CHECK_BATTERY_STATUS_PERIOD" }", $0); print $0 }')
	currentPercent=$(echo "$batteryData" | awk 'BEGIN { RS = ","; FS = ":" } /percentage/ { gsub(/^[ \t]+/, "", $2); print $2 }')
	batteryStatus=$(echo "$batteryData" | awk 'BEGIN { RS = ","; FS = ":" } /status/ { gsub(/^[ \t]+/, "", $2); print $2 }')
	health=$(echo "$batteryData" | awk 'BEGIN { RS = ","; FS = ":" } /health/ { gsub(/^[ \t]+/, "", $2); print $2 }')
	temperature=$(echo "$batteryData" | awk 'BEGIN { RS = ","; FS = ":" } /temperature/ { gsub(/^[ \t]+/, "", $2); print $2 }')
	NOT_CHARGING_STATUS="NOT_CHARGING"
	CHARGING_STATUS="CHARGING"
else
	#Получаем данные о состоянии батареии по файлам устройств из /sys (запуск из обычного терминала из под рут)
	#Обязательные переменные
	currentPercent=$(cat /sys/class/power_supply/battery/capacity) #Обязательно нужно получить текущий процент заряда батареии
	batteryStatus=$(cat /sys/class/power_supply/battery/status) #Обязательно нужно получить информацию о том, заряжается батарея или нет
	NOT_CHARGING_STATUS="Not charging"
	CHARGING_STATUS="Charging"
	#Необязательные переменные, просто для отображения информации в браузере
	health=$(cat /sys/class/power_supply/battery/health)
	voltage=$(cat /sys/class/power_supply/battery/batt_vol)
	temperature=$(($(cat /sys/class/power_supply/battery/batt_temp) / 10))
fi
	#Создаём итоговый JSON, который отправится на сервер
echo batteryData="{ \"percent\": $currentPercent, \"status\": $batteryStatus, \"health\": $health, \"voltage\": $voltage, \"temperature\": $temperature, \"checkPeriod\": $CHECK_BATTERY_STATUS_PERIOD }"
