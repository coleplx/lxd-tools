#!/bin/bash

function beta_cycling {
  source ./functions/lxc_commands.sh

  RUNNING_STAGINGS=$(lxc_list_running | grep '\-staging\-')

  for staging in $RUNNING_STAGINGS; do
    IS_SLEEP=$(is_sleeping "$staging")
    if [[ $IS_SLEEP -ne 3 ]]; then
      HOSTNAME_FIELD_COUNT=$(set +o pipefail; echo "$staging" | awk -F '-' '{print NF}')
      if [ "$HOSTNAME_FIELD_COUNT" -lt 4 ]; then
          STAGING_HOST=$(set +o pipefail; echo "$staging" | awk -F '-' '{print $NF}')
      else
          STAGING_HOST=$(set +o pipefail; echo "$staging" | awk -F '-' '{print $2}')
      fi
      PHP_VERSION=$(sudo nsenter -t "$(cat /var/snap/lxd/common/lxd.pid)" -m cat /var/snap/lxd/common/lxd/storage-pools/default/containers/"$staging"/rootfs/etc/nginx/sites/"$STAGING_HOST".conf | grep -o /php.*-fpm | awk -F '/' '{ print $2; }');
      
      lxcexec "${staging}" "timeout 30 systemctl restart mariadb $PHP_VERSION"
      operation_status=$?

      # Check the operation status - If it is still running, it's probably stuck and will disappear after the "timeout 30" is hit
      if [[ $operation_status == 103 ]]; then
        echo "$staging - Cycling timed-out after 25 seconds. Skipping to the next..."
      else
        echo "$staging cycled."
      fi
    fi
  done

}
