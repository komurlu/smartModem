#!/bin/bash
#This script should run on your home router/modem.
#It checks if one of either your TV Set-top-box or HTPC (home theater PC) is turned on.
#If one of those devices is on, script runs an action - turns on Smart Power Plug to control external speakers(or home thater)

export MIROBO_TOKEN=11111111111111aaaaaaaaaaaaabcdef  #xiaomi wifi plug (chaungmi ) token
export MIROBO_IP=192.168.1.9 #Xiaomi wifi plug IP

pingAddress=192.168.1.42 #Monitor is this device is alive
ethDevice=eth2 #Monitor if this interface has traffic
turnOffTimeout=60

control_c () {
echo killing
kill -SIGINT $(jobs -p)
exit #$
}

trap control_c SIGINT

speakerStatus=0;
oldTvUsage=0

ac () {
	echo "acildi";
	./sauger 1
	speakerStatus=1;
}

kapat () {
	echo "kapandi";
	./sauger 0
	speakerStatus=0;
}

while true; do
	#eth2 for modem
	oldTvUsage=$(cat /sys/class/net/$ethDevice/statistics/tx_bytes);
	sleep 1&wait
	newTvUsage=$(cat /sys/class/net/$ethDevice/statistics/tx_bytes);
	usageDiff=$(($newTvUsage-$oldTvUsage));

	ping -c 1 -W 1 $pingAddress > /dev/null; #replace with ZBOX
	pingSuccess=$? #//exit code to variable(0 ise succ, 1 ise fail)

	echo $usageDiff
	if [ $usageDiff -gt 10000 ] #//fazla trafik varsa
	then
		sleep 1&wait
		oldTvUsage=$(cat /sys/class/net/$ethDevice/statistics/tx_bytes);
		sleep 1&wait
		newTvUsage=$(cat /sys/class/net/$ethDevice/statistics/tx_bytes);
		usageDiff=$(($newTvUsage-$oldTvUsage));

		if [ $usageDiff -gt 10000 ] && [ $speakerStatus -eq 0 ]
		then
			echo "high usage speaker was off"
			ac;
		fi

	elif [ $pingSuccess -eq 0 ]
	then
		if [ $speakerStatus -eq 0 ] 
		then
			echo "ping success speaker was off"
			ac;
		fi

	else
		if [ $speakerStatus -eq 1 ]
		then
			echo "testing values again to turn off"
			sleep $turnOffTimeout&wait
			oldTvUsage=$(cat /sys/class/net/$ethDevice/statistics/tx_bytes);
			sleep 1&wait
			newTvUsage=$(cat /sys/class/net/$ethDevice/statistics/tx_bytes);
			usageDiff=$(($newTvUsage-$oldTvUsage));
			echo $usageDiff
			ping -c 1 -W 1 $pingAddress > /dev/null; 
			pingSuccess=$?

			if [ $usageDiff -lt 10000 ] && [ $pingSuccess -eq 1 ]
			then
				echo "no traffic no ping speaker was on"
				kapat;
			fi
		fi
	fi
	sleep 1&wait
done
