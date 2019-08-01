#!/bin/sh

/etc/init.d/logstash start
/etc/init.d/filebeat start

tail -f /dev/null
