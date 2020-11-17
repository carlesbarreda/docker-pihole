#!/bin/bash
ip route del 192.168.1.53/32 dev mac0
ip link set mac0 down
ip addr del 192.168.1.4/32 dev mac0
ip link del mac0 link eth0 type macvlan mode bridge
