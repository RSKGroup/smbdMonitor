#!/bin/sh

logFile="/Users/Shared/smbdMonitor.log"

function logAction {
        logTime=$(date "+%Y-%m-%d - %H:%M:%S:")
        echo "$logTime" "$1" >> "$logFile"
}

smbdPID=$(pgrep smbd)
if [ -n $smbdPID ]; then
	smbdUsage=$(top -l 2 -stats cpu -pid $smbdPID | tail -n 1 | cut -f1 -d".")
	echo $smbdUsage >> /tmp/lastXsmbd.txt
	numberOfLines=$(wc -l /tmp/lastXsmbd.txt | awk '{print $1}')
	if [ $numberOfLines -gt 10 ]; then
		savedLines=$(tail -n 10 /tmp/lastXsmbd.txt)
		echo "$savedLines" > /tmp/lastXsmbd.txt
	fi

	totalUsage=0
	while read value; do
		if [ -n $value ]; then
			totalUsage=$(expr $totalUsage + $value)
		fi
	done < /tmp/lastXsmbd.txt

	if [ $totalUsage -gt 1050 ]; then
		logAction "Will kill smbd ($smbdPID) PID as total usage is $totalUsage"
		killall smbd
	else
		logAction "Total usage only $totalUsage"
	fi
fi
