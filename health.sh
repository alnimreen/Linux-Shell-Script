#!/bin/bash

check_disk_space() {
  echo "Disk Space Usage:"
  df -h 
  echo ""
}

check_memory_usage() {
  echo "Memory Usage:"
  free -h
  mem_free=$(free -m | awk '/^Mem:/ {print int($7/$2 * 100.0)}') 
    echo "Free memory is $mem_free% of total."
    if [[ $mem_free -lt 20 ]]; then
        echo "Recommendation: Free memory is low at $mem_free%. Consider adding more memory or closing some applications."
    else
        echo "Free memory is at a healthy level."
    fi
  echo ""
}

check_running_services() {
  echo "Running Services:"
   service --status-all | grep '+'
  echo ""
}

check_recent_updates() {
  echo "Recent System Updates:"
  if [ -x "$(command -v apt)" ]; then
    upgradable_packages=$(apt list --upgradable 2> /dev/null | grep -v "^Listing..." | head -n 10)
    
    if [ -z "$upgradable_packages" ]; then
      echo "All packages are up to date."
    else
      echo "$upgradable_packages" | while IFS= read -r line
      do
        echo ""
        echo "$line"
      done
    fi
    
  elif [ -x "$(command -v yum)" ]; then
    yum check-update | head -n 10
  else
    echo "Package manager not supported."
  fi
  echo ""
}


while true; do
  clear
  echo "System Health Report"
  echo "===================="
  check_disk_space
  check_memory_usage
  check_running_services
  check_recent_updates
  sleep 2
done
