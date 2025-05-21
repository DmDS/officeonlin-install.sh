sed -i 's/capabilities desc="Should we require capabilities to isolate processes into chroot jails" type="bool" default="true">true</capabilities desc="Should we require capabilities to isolate processes into chroot jails" type="bool" default="true">false</' /etc/coolwsd/coolwsd.xml
service coolwsd restart
