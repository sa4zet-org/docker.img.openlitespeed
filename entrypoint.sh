#!/bin/bash

if [[ -z "$(ls -A /usr/local/lsws/conf)" ]]; then
  cp -r /usr/local/lsws/.conf/* /usr/local/lsws/conf/
fi
if [[ -z "$(ls -A /usr/local/lsws/admin/conf)" ]]; then
  cp -r /usr/local/lsws/admin/.conf/* /usr/local/lsws/admin/conf/
fi

chown -R lsadm:nogroup {/usr/local/lsws,/var/lib/lsphp84/,/var/lib/php}

cleanup() {
    echo 'Stopping LiteSpeed...'
    lswsctrl stop
    exit 0
}

trap cleanup SIGTERM SIGINT

/usr/local/lsws/bin/lswsctrl start

tail -f /tmp/lshttpd/lshttpd.pid &
TAIL_PID=$!

wait $TAIL_PID
