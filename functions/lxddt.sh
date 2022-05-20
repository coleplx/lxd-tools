#!/bin/bash
# ./lxddt.sh


function lxddt {
  source ./functions/lxc_commands.sh

  MAX_RUNNING_LXC=$(grep LXD_META_NUMBER_OF_RUNNING_CONTAINERS /var/log/syslog{.1,} | tail -1 | rev | cut -d' ' -f1 | rev)
  CURRENT_RUNNING_LXC=$(lxc_list_running | wc -l)

  FIRST_LIVE_CONTAINER_NAME=$(sudo cat /var/snap/lxd/common/lxd/logs/lxd.log | grep 'Started container' | grep -v '\-staging\-' | head -n1 | egrep -o "(instance|name)=.*" | cut -d'=' -f2 | cut -d' ' -f1)
  FIRST_LIVE_CONTAINER_TIME=$(sudo cat /var/snap/lxd/common/lxd/logs/lxd.log | grep 'Started container' | grep "$FIRST_LIVE_CONTAINER_NAME" | head -n1 | cut -d' ' -f1 | egrep -o '[0-9]+:[0-9]+')

  LAST_LIVE_CONTAINER_NAME=$(sudo cat /var/snap/lxd/common/lxd/logs/lxd.log | grep 'Started container' | grep -v '\-staging\-' | tail -n1 | egrep -o "(instance|name)=.*" | cut -d'=' -f2 | cut -d' ' -f1)
  LAST_LIVE_CONTAINER_TIME=$(sudo cat /var/snap/lxd/common/lxd/logs/lxd.log | grep 'Started container' | grep "$LAST_LIVE_CONTAINER_NAME" | tail -n1 | cut -d' ' -f1 | egrep -o '[0-9]+:[0-9]+')

  echo ""
  echo "Time now: $(date '+%H:%M') UTC"
  echo ""
  echo "Running / Max"
  echo "    $CURRENT_RUNNING_LXC / $MAX_RUNNING_LXC"
  echo ""
  echo "First live container started:
  $FIRST_LIVE_CONTAINER_NAME @ $FIRST_LIVE_CONTAINER_TIME UTC"
  echo "Last live container started:
  $LAST_LIVE_CONTAINER_NAME @ $LAST_LIVE_CONTAINER_TIME UTC"
  echo ""
  echo "Last uptime:"
  grep LXD_META_UP_SINCE /var/log/syslog{.1,} | tail -1 | rev | cut -d' ' -f1-2 | rev
  echo ""

}
