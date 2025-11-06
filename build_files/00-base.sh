#!/bin/bash

set -xeuo pipefail

systemctl enable systemd-timesyncd
systemctl enable systemd-resolved.service

pacman -Syyuu --noconfirm tailscale && \
  pacman -S --clean && \
  rm -rf /var/cache/pacman/pkg/*

systemctl enable tailscaled

pacman -Syyuu --noconfirm \
	networkmanager \
	linux-firmware \
	linux-firmware-amdgpu \
	linux-firmware-atheros \
	linux-firmware-broadcom \
	linux-firmware-intel \
	linux-firmware-mediatek \
	linux-firmware-other \
	linux-firmware-radeon \
	linux-firmware-realtek && \
pacman -S --clean && \
rm -rf /var/cache/pacman/pkg/*

# This package adds "[systemd] Failed Units: *" to the bashrc startup
#dnf -y remove console-login-helper-messages \
#    chrony
#
#I don't know if I need this? Keeping it here just in case idk

pacman -Syyuu --noconfirm alsa-firmware && \
  pacman -S --clean && \
  rm -rf /var/cache/pacman/pkg/*

pacman -Syyuu --noconfirm \
	cifs-utils \
	firewalld \
	fuse2 \
	fuse3 \
	fuse-common \
	fwupd  \
	gvfs-smb \
	ifuse \
	libcamera \
	gst-plugin-libcamera \
	libcamera-tools \
	libimobiledevice \
	man-db \
	plymouth \
	rclone \
	systemd \
	tuned \
	tuned-ppd \
	unzip \
	whois && \
pacman -S --clean && \
rm -rf /var/cache/pacman/pkg/*

#systemctl enable firewalld

sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer

systemctl enable bootc-fetch-apply-updates

#tee /usr/lib/systemd/zram-generator.conf <<'EOF'
#[zram0]
#zram-size = min(ram, 8192)
#EOF

tee /usr/lib/systemd/system-preset/91-resolved-default.preset <<'EOF'
enable systemd-resolved.service
EOF
tee /usr/lib/tmpfiles.d/resolved-default.conf <<'EOF'
L /etc/resolv.conf - - - - ../run/systemd/resolve/stub-resolv.conf
EOF

systemctl preset systemd-resolved.service

#dnf -y copr enable ublue-os/packages
#dnf -y copr disable ublue-os/packages
#dnf -y --enablerepo copr:copr.fedorainfracloud.org:ublue-os:packages install \
#	ublue-brew \
#	uupd \
#	ublue-os-udev-rules

# ts so annoying :face_holding_back_tears: :v: 67
#sed -i 's|uupd|& --disable-module-distrobox|' /usr/lib/systemd/system/uupd.service

#systemctl enable brew-setup.service
#systemctl enable uupd.timer

#dnf -y copr enable ublue-os/flatpak-test
#dnf -y copr disable ublue-os/flatpak-test
#dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak flatpak
#dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-libs flatpak-libs
#dnf -y --repo=copr:copr.fedorainfracloud.org:ublue-os:flatpak-test swap flatpak-session-helper flatpak-session-helper
#rpm -q flatpak --qf "%{NAME} %{VENDOR}\n" | grep ublue-os
