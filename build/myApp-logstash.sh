#!/bin/sh

/etc/init.d/logstash start
/etc/init.d/filebeat run

tail -f /dev/null
