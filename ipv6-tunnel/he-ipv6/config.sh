#!/bin/sh

PUBLIC_IP=`/bin/ip route get 255.255.255.255 | awk -F ' ' 'BEGIN {RS=""}{gsub(/\n/,"",$0); print $6}'`
USER="Stricted"
TUNNEL="" # tunnel id
PASSWORD="" # tunnel password

# these are example values, this tunnel is not used
HEIPV4SERVER="216.66.80.30"
HEIPV6CLIENT="2001:470:1f0a:2e::2"
LOCALIP1="2001:470:1f0b:2f::1/64"
SUBNET="2001:470:1f0b:2f::/64"

TUNNELNAME="he-ipv6"
BRIDGE="br0"

FILE=/opt/root/public_ip
