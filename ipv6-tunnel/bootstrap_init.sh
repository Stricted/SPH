#!/bin/sh

# wait for dsl connection
while [ $(date | cut -d ' ' -f 7) = 1970 ]; do sleep 1 ; done

# allow pings for ipv6 tunnel
/bin/iptables -D INPUT_FIREWALL ! -i br0 -p all -j DROP
/bin/iptables -A INPUT_FIREWALL ! -i br0 -p icmp -j ACCEPT
/bin/iptables  -A INPUT_FIREWALL -p 41 -j ACCEPT
/bin/iptables -A INPUT_FIREWALL ! -i br0 -p all -j DROP


/opt/he-ipv6/start_tunnel.sh
/opt/he-ipv6/ip6t.sh
/opt/bin/busybox-mips crond -L /opt/var/log/crond.log -c /opt/etc/cron.d
