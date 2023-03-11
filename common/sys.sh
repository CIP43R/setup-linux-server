#!/bin/bash

backup() {
  backup_folder=$cwd/backups/$2
  mkdir -p $backup_folder
  sudo cp $1 $backup_folder
  log "Created a copy of $2 config in $backup_folder" INFO
}
update() {
  # Make sure to backup important config files before update
  backup "/etc/netplan/*" "netplan"
  
  log "Installing updates...this may take a while" INFO
  { 
    touch $cwd/logs/install.log
    touch $cwd/logs/full.log
    sudo apt update && apt upgrade -y
  } &> $aptlogloc
  log "Updated system packages" INFO
}
jail() {
  if [[ $(command_exists "fail2ban") = false ]]; then
    log "fail2ban installation not found. Installing now..." LOG
    install_fail2ban
  fi
  log "Enabling fail2ban jail $1" VERBOSE
  replace "[$1]" "[$1]\nenabled=true" /etc/fail2ban/jail.local
}
nginx_ok() {
  out=$(nginx -t 2>&1)
  if $out; then
    echo true
  else
    $out > $cmdlogloc
    echo false
  fi
}
silent_tee() {
  echo -e "\n$1" | sudo tee -a $2 &> /dev/null 
}