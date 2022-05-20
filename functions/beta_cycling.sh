#!/bin/bash

function beta_cycling {
  source ./functions/lxc_commands.sh

for staging in $(lxc_list_running | grep '\-staging\-');
do
  IS_SLEEP=$(is_sleeping $staging)
  if [[ $IS_SLEEP -ne 3 ]]; then
    STAGING_HOST=$(sudo nsenter -t $(cat /var/snap/lxd/common/lxd.pid) -m cat /var/snap/lxd/common/lxd/storage-pools/default/containers/$staging/rootfs/etc/hostname | awk -F '-' '{print $NF}');
    PHP_VERSION=$(sudo nsenter -t $(cat /var/snap/lxd/common/lxd.pid) -m cat /var/snap/lxd/common/lxd/storage-pools/default/containers/$staging/rootfs/etc/nginx/sites/$STAGING_HOST.conf | grep -o /php.*-fpm | awk -F '/' '{ print $2; }');
    #if lxc exec $staging systemctl try-restart mariadb $PHP_VERSION;then
    #  echo $staging cycled
    #else
    #  echo Something failed when cycling $staging;
    #fi
    echo $staging not sleeping - restarting
  fi
done

}
