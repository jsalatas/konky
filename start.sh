#!/bin/sh
killall conky
conky -c clock/conkyrc &
conky -c date/conkyrc &
conky -c graphs/conkyrc_cpu &
conky -c graphs/conkyrc_network &
conky -c graphs/conkyrc_memory &
conky -c disk/conkyrc &
