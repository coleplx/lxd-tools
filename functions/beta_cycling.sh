#!/bin/bash

function beta_cycling {
  source ./functions/lxc_commands.sh

  RUNNING_STAGINGS=$(lxc_list_running | grep '\-staging\-')

  ### LXD API IMPLEMENTATION
  get_stderr_code() {
      id_container=$1
      id_operation=$2
      stderr_log=$(curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket lxd/1.0/instances/${id_container}/logs/exec_${id_operation}.stderr)
  }
  get_stdout() {
      id_container=$1
      id_operation=$2
      curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket lxd/1.0/instances/${id_container}/logs/exec_${id_operation}.stdout
  }
  get_stderr() {
      id_container=$1
      id_operation=$2
      curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket lxd/1.0/instances/${id_container}/logs/exec_${id_operation}.stderr
  }
  get_return_code() {
      parse_log="$1"
      return_code=$(echo "$parse_log" | sed -e 's/,/\n/g' | egrep -o '"return":[0-9]' | cut -d':' -f2)
      echo $return_code
  }
  get_operation_status() {
      parse_log="$1"
      operation_status=$(echo "$parse_log" | sed -e 's/,/\n/g' | grep status_code | tail -n1 | cut -d':' -f2)
      echo $operation_status
  }

  for staging in $RUNNING_STAGINGS; do
    IS_SLEEP=$(is_sleeping $staging)
    if [[ $IS_SLEEP -ne 3 ]]; then
      HOSTNAME_FIELD_COUNT=$(set +o pipefail; echo $staging | awk -F '-' '{print NF}')
      if [ "$HOSTNAME_FIELD_COUNT" -lt 4 ]; then
          STAGING_HOST=$(set +o pipefail; echo $staging | awk -F '-' '{print $NF}')
      else
          STAGING_HOST=$(set +o pipefail; echo $staging | awk -F '-' '{print $2}')
      fi
      PHP_VERSION=$(sudo nsenter -t $(cat /var/snap/lxd/common/lxd.pid) -m cat /var/snap/lxd/common/lxd/storage-pools/default/containers/$staging/rootfs/etc/nginx/sites/$STAGING_HOST.conf | grep -o /php.*-fpm | awk -F '/' '{ print $2; }');
      
      operation_id=$(curl -sX POST  --unix-socket /var/snap/lxd/common/lxd/unix.socket a/1.0/instances/${staging}/exec -d '{ "command": [ "bash", "-c", "timeout 30 systemctl try-restart mariadb '$PHP_VERSION'"  ], "record-output": true }' | sed -e 's/,/\n/g' | grep operation | cut -d'"' -f4)
      operation_id_simple=$(echo ${operation_id} | rev | cut -d'/' -f1 | rev)
      # Wait for the command to finish (or timeout in 25 seconds)
      operation_result=$(curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket lxd${operation_id}/wait?timeout=25)
      operation_status=$(get_operation_status "${operation_result}")
      # Check the operation status - If it is still running, it's probably stuck and will disappear after the "timeout 30" is hit
      if [[ $operation_status == 103 ]]; then
        echo "$staging - Cycling timed-out after 25 seconds. Skipping to the next..."
      else
        # Get return code and outputs - Comment these if you don't want ANY output
        get_stdout ${staging} ${operation_id_simple}
        get_stderr ${staging} ${operation_id_simple}
        #return_code=$(get_return_code "${operation_result}") # We probably don't need it here
        echo "$staging cycled."
      fi
    fi
  done

}
