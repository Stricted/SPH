#/bin/sh

source /opt/he-ipv6/config.sh

# update tunnel endpoint address on he.net
UPDATE=`/opt/bin/busybox-mips wget http://ipv4.tunnelbroker.net/nic/update?username=$USER\&password=$PASSWORD\&hostname=$TUNNEL -q -O - "$@"`

# possible return values
# nochg xxx.xxx.xxx.xxx  # ip not changed
# good 127.0.0.1         # ip not pingable
# good xxx.xxx.xxx.xxx   # ip changed

if [ "$UPDATE" == "good 127.0.0.1" ];
then
	echo "ip not pingable"
elif [ "$UPDATE" == "good $PUBLIC_IP" ];
then
	/bin/ip tunnel add $TUNNELNAME mode sit remote $HEIPV4SERVER local $PUBLIC_IP ttl 255
	/bin/ip link set $TUNNELNAME up
	/bin/ip addr add $HEIPV6CLIENT dev $TUNNELNAME
	/bin/ip -6 route add ::/0 dev $TUNNELNAME
	/bin/ip -6 route add 2000::/3 dev $TUNNELNAME
	/bin/ip -6 addr add $LOCALIP1 dev $BRIDGE
	
	echo "ip changed"
	echo $PUBLIC_IP > $FILE
fi
