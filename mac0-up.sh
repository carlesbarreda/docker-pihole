#!/bin/bash
ip link add mac0 link eth0 type macvlan mode bridge
ip addr add 192.168.1.4/32 dev mac0
ip link set mac0 up
ip route add 192.168.1.53/32 dev mac0
