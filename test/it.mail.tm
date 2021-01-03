#!/bin/bash
CMD="swaks -f user1@sylo.space -t fptllp@effobe.com -s smtp.sylo.space -p 587 --auth-user user1 --auth-password password1 $1 # -tls"
echo $CMD
$CMD

