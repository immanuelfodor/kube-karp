#!/bin/sh

# cleanup when the container is stopped or ucarp exits
cleanup () {
  kill -USR2 $(pidof ucarp)
  sleep 1
  $KARP_DOWNSCRIPT $KARP_INTERFACE $KARP_VIRTUAL_IP $KARP_SUBNET
}
trap "cleanup" SIGINT
trap "cleanup" SIGTERM

cat-file-with-header() {
  echo "==> $1 <=="
  cat "$1"
  echo
}

# set the debug env var to anything for debug logging
if [ ! -z "${KARP_DEBUG}" ] ; then
  set -x
  cat-file-with-header /etc/conf.d/ucarp
  cat-file-with-header /etc/init.d/ucarp
  cat-file-with-header "$KARP_DOWNSCRIPT"
  cat-file-with-header "$KARP_UPSCRIPT"
  /usr/sbin/ucarp --help
fi

# if no explicit host ip is set, we determine it from the interface
if [ -z "${KARP_HOST_IP}" ] ; then
  KARP_HOST_IP=$(ip addr show ${KARP_INTERFACE} | grep inet | grep -v secondary | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -n 1)
  echo "Auto host IP: ${KARP_HOST_IP}"
fi

# start up the service and put it into background
/usr/sbin/ucarp \
  --interface=${KARP_INTERFACE} \
  --srcip=${KARP_HOST_IP} \
  --vhid=${KARP_SERVER_ID} \
  --pass=${KARP_PASSWORD} \
  --addr=${KARP_VIRTUAL_IP} \
  --upscript=${KARP_UPSCRIPT} \
  --downscript=${KARP_DOWNSCRIPT} \
  --xparam=${KARP_SUBNET} \
  ${KARP_EXTRA_FLAGS} &

# wait for the last process sent to background to finish (ucarp)
wait $!

# cleanup even if the process exits by itself
# otherwise, the traps handle container stops initiated by the user
cleanup
