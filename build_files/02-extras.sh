#!/usr/bin/env bash

set -xeuo pipefail

systemctl enable --global ssh-agent

pacman -Syyuu --noconfirm \
	docker \
	docker-compose && \
pacman -S --clean && \
rm -rf /var/cache/pacman/pkg/*

#Not required ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose
mkdir -p /usr/lib/sysctl.d
echo "net.ipv4.ip_forward = 1" >/usr/lib/sysctl.d/docker-ce.conf

mkdir -p /usr/lib/systemd/system-preset
touch /usr/lib/systemd/system-preset/90-default.preset
sed -i 's/enable docker/disable docker/' /usr/lib/systemd/system-preset/90-default.preset
systemctl preset docker.service docker.socket

cat >/usr/lib/sysusers.d/docker.conf <<'EOF'
g docker -
EOF
