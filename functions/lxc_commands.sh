#!/bin/bash
# A bunch of handy functions to replicate and/or optimize the lxc binary
# 

# Return a list of running containers
function lxc_list_running {
  ls -ld /sys/fs/cgroup/memory/lxc.payload* | rev | cut -d'.' -f1 | rev
}

# Check if the container is sleeping
function is_sleeping {
  if [ -z $1 ]; then
    echo "Missing argument"
    return 1
  else
    sudo nsenter -t $(cat /var/snap/lxd/common/lxd.pid) -m \
    cat /var/snap/lxd/common/lxd/storage-pools/default/containers/$1/rootfs/kinsta/main.conf | grep sleep |  awk -F '=' '{print $2}'
  fi
}

# Return the memory usage (in bytes) and container name
function container_mem_usage {
  if [ -z $1 ]; then
    echo "Missing argument"
    return 1
  else
    MEM_IN_BYTES=$(cat /sys/fs/cgroup/memory/lxc.payload.${1}/memory.usage_in_bytes)
    echo $MEM_IN_BYTES $1
  fi
}