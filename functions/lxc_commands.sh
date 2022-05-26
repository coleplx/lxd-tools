#!/bin/bash
# A bunch of handy functions to replicate and/or optimize the lxc binary
# 

# Return a list of running containers
function lxc_list_running {
  find /sys/fs/cgroup/memory/lxc.payload* -maxdepth 0  | rev | cut -d'.' -f1 | rev
}

# Check if the container is sleeping
function is_sleeping {
  if [ -z "$1" ]; then
    echo "Missing argument"
    return 1
  else
    sudo nsenter -t "$(cat /var/snap/lxd/common/lxd.pid)" -m \
    cat /var/snap/lxd/common/lxd/storage-pools/default/containers/"$1"/rootfs/kinsta/main.conf | grep sleep |  awk -F '=' '{print $2}'
  fi
}

# Return the memory usage (in bytes) and container name
function container_mem_usage {
  if [ -z "$1" ]; then
    echo "Missing argument"
    return 1
  else
    MEM_IN_BYTES=$(cat /sys/fs/cgroup/memory/lxc.payload."${1}"/memory.usage_in_bytes)
    echo "$MEM_IN_BYTES $1"
  fi
}

# Use the LXD API to exec commands on containers
# USE WITH CAUTION - Escaping some characters can be tricky and error-prone.
# If your command has special characters (any non-alphanumeric char), please test in a dev environment first
function get_stderr_code {
  id_container=$1
  id_operation=$2
  curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket "lxd/1.0/instances/${id_container}/logs/exec_${id_operation}.stderr"
}
function get_stdout {
  id_container=$1
  id_operation=$2
  curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket "lxd/1.0/instances/${id_container}/logs/exec_${id_operation}.stdout"
}
function get_stderr {
  id_container=$1
  id_operation=$2
  curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket "lxd/1.0/instances/${id_container}/logs/exec_${id_operation}.stderr"
}
function get_operation_status {
  parse_log="$1"
  echo "$parse_log" | sed -e 's/,/\n/g' | grep status_code | tail -n1 | cut -d':' -f2
}

function lxcexec { 
  container=$1
  timeout=$2
  command="$(echo "${@:3}" | sed -e "s/\\\\/\\\\\\\\/g")"
  command2='{ "command": [ "bash", "-c", "'$command'"  ], "record-output": true }'
  temp_file="/tmp/json_$RANDOM"
  echo "$command2" > $temp_file

  # The exec command is sent here and the API immediately returns an operation ID
  # We need this operation ID to actually check the command output
  operation_output=$(curl -sX POST --unix-socket /var/snap/lxd/common/lxd/unix.socket "a/1.0/instances/${container}/exec" -d @$temp_file --header "Content-Type: application/json")
  operation_id=$(echo "$operation_output" | jq .operation | cut -d'"' -f2)
  operation_id_simple=$(echo "$operation_output" | jq .metadata.id | cut -d'"' -f2)

  # The command will timeout and be canceled in {{ timeout }} seconds
  operation_result=$(curl -s --unix-socket /var/snap/lxd/common/lxd/unix.socket lxd"${operation_id}"/wait?timeout="${timeout}")
  operation_status=$(get_operation_status "$operation_result")
  
  get_stdout "${container}" "${operation_id_simple}"
  get_stderr "${container}" "${operation_id_simple}"

  rm -f "$temp_file"

  if [[ $operation_status == 103 ]]; then
    return 103
  fi
}
