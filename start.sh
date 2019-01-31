#!/bin/sh
cd ~/.conky
killall conky
sleep 10
conky -dqc clock/conkyrc
conky -dqc date/conkyrc
conky -dqc graphs/conkyrc_cpu
conky -dqc graphs/conkyrc_network
conky -dqc graphs/conkyrc_memory
conky -dqc disk/conkyrc
conky -dqc sensors/conkyrc
conky -dqc processes/conkyrc_cpu
conky -dqc processes/conkyrc_memory
