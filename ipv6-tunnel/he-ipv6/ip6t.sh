#/bin/sh

source /opt/he-ipv6/config.sh

# create chain
/bin/ip6tables -N HE_INPUT
/bin/ip6tables -N HE_FORWARD
/bin/ip6tables -N HE_OUTPUT

# add chain on top
/bin/ip6tables -I INPUT 1 -j HE_INPUT
/bin/ip6tables -I FORWARD 1 -j HE_FORWARD
/bin/ip6tables -I OUTPUT 1 -j HE_OUTPUT

# remove not needed rules
/bin/ip6tables -D INPUT -j INPUT_FIREWALL
/bin/ip6tables -D FORWARD -j FORWARD_FIREWALL
/bin/ip6tables -D FORWARD -j FORWARD_PREFIX
/bin/ip6tables -D FORWARD_DT ! -i br+ -p icmpv6 -j FORWARD_ICMP_WAN

# fill HE_INPUT
/bin/ip6tables -A HE_INPUT  -i lo -j ACCEPT
/bin/ip6tables -A HE_INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
/bin/ip6tables -A HE_INPUT -p ipv6-icmp -m icmp6 --icmpv6-type echo-request -j ACCEPT
/bin/ip6tables -A HE_INPUT -p ipv6-icmp -m icmp6 --icmpv6-type destination-unreachable -j ACCEPT
/bin/ip6tables -A HE_INPUT -i $BRIDGE -p ipv6-icmp -m icmp6 --icmpv6-type neighbour-solicitation -j ACCEPT
/bin/ip6tables -A HE_INPUT -i $BRIDGE -p ipv6-icmp -m icmp6 --icmpv6-type neighbour-advertisement -j ACCEPT
/bin/ip6tables -A HE_INPUT  -i $TUNNELNAME -m state --state ESTABLISHED,RELATED -j ACCEPT
/bin/ip6tables -A HE_INPUT -d ff00::/8 -j ACCEPT
/bin/ip6tables -I HE_INPUT  -p icmpv6 -j ACCEPT

# drop telnet connection, this is important
/bin/ip6tables -I HE_INPUT -p tcp --dport 23 ! -s $SUBNET -j DROP

# fill HE_FORWARD
/bin/ip6tables -A HE_FORWARD ! -s $SUBNET -i $BRIDGE -j REJECT --reject-with icmp6-dst-unreachable
/bin/ip6tables -A HE_FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
/bin/ip6tables -A HE_FORWARD -p ipv6-icmp -m icmp6 --icmpv6-type echo-request -j ACCEPT
/bin/ip6tables -A HE_FORWARD -p ipv6-icmp -m icmp6 --icmpv6-type destination-unreachable -j ACCEPT
/bin/ip6tables -A HE_FORWARD -i $BRIDGE -o $TUNNELNAME -j ACCEPT
/bin/ip6tables -A HE_FORWARD -m state --state NEW -i $BRIDGE -o $TUNNELNAME -s $SUBNET -j ACCEPT
/bin/ip6tables -A HE_FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
/bin/ip6tables -I HE_FORWARD -p icmpv6 -j ACCEPT

# fill HE_OUTPUT
/bin/ip6tables -A HE_OUTPUT -o lo -j ACCEPT
/bin/ip6tables -A HE_OUTPUT -o $TUNNELNAME -j ACCEPT
/bin/ip6tables -A HE_OUTPUT -d ff00::/8 -j ACCEPT
/bin/ip6tables -I HE_OUTPUT -p icmpv6 -j ACCEPT

# mangle table
/bin/ip6tables -t mangle -A PRE_LAN_SUBNET -s $SUBNET -i $BRIDGE -j ACCEPT
/bin/ip6tables -t mangle -A ROUTE_CTL_LIST -d $SUBNET -j RETURN
