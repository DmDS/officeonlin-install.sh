#!/bin/bash
# shellcheck disable=SC2154
# tests script

JAILS_DIR="/opt/cool/jails"

if [ ! -d "${JAILS_DIR}" ]; then
  echo "Jails directory not found. Creating ${JAILS_DIR}..."
  mkdir -p "${JAILS_DIR}"
fi

CURRENT_OWNER=$(stat -c '%U:%G' "${JAILS_DIR}")
if [ "$CURRENT_OWNER" != "cool:cool" ]; then
  echo "Fixing permissions for ${JAILS_DIR} (current: $CURRENT_OWNER)..."
  chown -R cool:cool "${JAILS_DIR}"
fi

systemctl start $coolwsd_service_name.service
rm -rf ${lo_dir}/workdir
sleep 18

if pgrep -u cool coolwsd; then
  clear
  echo -e "\033[33;7m### coolwsd is running. Enjoy!!! ###\033[0m"
  lsof -i :9980
  systemctl enable $coolwsd_service_name.service
  systemctl daemon-reload
else
  echo -e "\033[33;5m### coolwsd is not running. Something went wrong :| Please look in ${log_dir} or try to restart your system ###\033[0m"
fi
