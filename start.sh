#!/bin/sh
cd ~/.conky
killall conky
conky -c clock/conkyrc &
conky -c date/conkyrc &
conky -c graphs/conkyrc_cpu &
conky -c graphs/conkyrc_network &
conky -c graphs/conkyrc_memory &
conky -c disk/conkyrc &
conky -c sensors/conkyrc &
#conky -c processes/conkyrc_cpu &
#conky -c processes/conkyrc_memory &
