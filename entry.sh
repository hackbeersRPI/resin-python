#!/bin/bash
/etc/init.d/shellinabox start \
	&& /usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg
