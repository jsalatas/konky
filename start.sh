#!/bin/sh
cd ~/.conky
killall conky
conky -c clock/conkyrc &
sleep 1
conky -c date/conkyrc &
sleep 1
conky -c graphs/conkyrc_cpu &
sleep 1
conky -c graphs/conkyrc_network &
sleep 1
conky -c graphs/conkyrc_memory &
sleep 1
conky -c disk/conkyrc &
sleep 1
conky -c sensors/conkyrc &
sleep 1
conky -c processes/conkyrc_cpu &
sleep 1
conky -c processes/conkyrc_memory &
sleep 1
