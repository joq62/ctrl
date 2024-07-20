#!/bin/bash
/usr/bin/erl -pa /home/ubuntu/system_boot/ebin -sname system_boot_a  -setcookie a -run system_boot start -hidden -noinput &
echo "$!" > /run/sys_boot.pid
