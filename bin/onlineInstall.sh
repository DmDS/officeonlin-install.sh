#!/bin/bash
# shellcheck disable=SC2154
# install script
#####################
#### coolwsd Installation ###

mkdir -p /etc/coolwsd
mkdir -p "${cool_localstatedir}/cache/coolwsd" && chown -R cool:cool "${cool_localstatedir}/cache/coolwsd"

make install

# 2. ПРОВЕРКА И ВОССТАНОВЛЕНИЕ
if [ -f /tmp/coolwsd.xml.backup ]; then
  echo "Restoring original coolwsd.xml from backup..."
  mv -f /tmp/coolwsd.xml.backup /etc/coolwsd/coolwsd.xml
elif [ -f "${cool_dir}/coolwsd.xml" ]; then
  echo "Moving new coolwsd.xml to /etc/coolwsd/"
  mv "${cool_dir}/coolwsd.xml" /etc/coolwsd/coolwsd.xml
fi

chown cool:cool /etc/coolwsd/coolwsd.xml
[ -n "$allowed_domains" ] && addwopihost /etc/coolwsd/coolwsd.xml "$allowed_domains"

# create log file for cool user
if [ -n "${cool_logfile}" ]; then
  [ ! -f ${cool_logfile} ] && touch ${cool_logfile}
  chown cool:cool ${cool_logfile}
fi

if [ ! -f /lib/systemd/system/$coolwsd_service_name.service ]; then
  [ -z "$admin_pwd" ] && admin_pwd=$(randpass 10 0)
  cat <<EOT > /lib/systemd/system/$coolwsd_service_name.service
[Unit]
Description=LibreOffice OnLine WebSocket Daemon
After=network.target

[Service]
EnvironmentFile=-/etc/sysconfig/coolwsd
ExecStartPre=/bin/mkdir -p /usr/local/var/cache/coolwsd
ExecStartPre=/bin/chown cool: /usr/local/var/cache/coolwsd
PermissionsStartOnly=true
ExecStart=${cool_dir}/coolwsd --o:sys_template_path=${cool_dir}/systemplate --o:lo_template_path=${cool_dir}/engine/instdir --o:child_root_path=${cool_dir}/jails --o:admin_console.username=admin --o:admin_console.password="$admin_pwd"
User=cool
KillMode=control-group
# Restart=always

[Install]
WantedBy=multi-user.target
EOT
fi

if [ ! -f /etc/coolwsd/ca-chain.cert.pem ]; then
  echo "Generating self-signed certificates..."
  openssl genrsa -out /etc/coolwsd/key.pem 4096
  openssl req -out /etc/coolwsd/cert.csr -key /etc/coolwsd/key.pem -new -sha256 -nodes -subj "/C=DE/OU=onlineoffice-install.com/CN=onlineoffice-install.com/emailAddress=nomail@nodo.com"
  openssl x509 -req -days 1825 -in /etc/coolwsd/cert.csr -signkey /etc/coolwsd/key.pem -out /etc/coolwsd/cert.pem
  openssl x509 -req -days 1825 -in /etc/coolwsd/cert.csr -signkey /etc/coolwsd/key.pem -out /etc/coolwsd/ca-chain.cert.pem
  chown cool:cool /etc/coolwsd/key.pem
  chmod 600 /etc/coolwsd/key.pem
fi

if [ ! -e /etc/systemd/system/$coolwsd_service_name.service ]; then
  ln -s /lib/systemd/system/$coolwsd_service_name.service /etc/systemd/system/$coolwsd_service_name.service
fi
