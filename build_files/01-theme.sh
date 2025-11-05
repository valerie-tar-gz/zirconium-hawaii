#!/bin/bash

set -xeuo pipefail

install -d /usr/share/zirconium/


rm -rf /usr/share/doc/niri

rm -rf /usr/share/doc/just

pacman -Syyuu --noconfirm \
	ghostty \
	cliphist && \
pacman -S --clean && \
rm -rf /var/cache/pacman/pkg/*

pacman -Syyuu --noconfirm \
	brightnessctl \
	jq \
	cava \
	chezmoi \
	ddcutil \
	fastfetch \
	flatpak \
	fzf \
	git \
	ffmpeg-thumbnail \
	tumbler \
	just \
	nautilus \
	orca \
	pipewire \
	udiskie \
	webp-pixbuf-loader \
	wireplumber \
	wl-clipboard \
	wlsunset \
	xdg-desktop-portal-gnome \
	xwayland-satellite \
	gnome-keyring \
	docker \
	docker-compose && \
pacman -S --clean && \
rm -rf /var/cache/pacman/pkg/*

#Reinstalling packages that cause issues with their services, idk firewalld gnome-keyring
pacman -Syyuu --noconfirm --overwrite greetd && \
pacman -S --clean && \
rm -rf /var/cache/pacman/pkg/*

pacman -Syyuu --noconfirm \
	kirigami \
	qt6ct \
	polkit-kde-agent \
	breeze \
	qqc2-desktop-style && \
pacman -S --clean && \
rm -rf /var/cache/pacman/pkg/*

touch /etc/pam.d/greetd
sed -i '/gnome_keyring.so/ s/-auth/auth/ ; /gnome_keyring.so/ s/-session/session/' /etc/pam.d/greetd
cat /etc/pam.d/greetd

sed -i "s/After=.*/After=graphical-session.target/" /usr/lib/systemd/user/plasma-polkit-agent.service

pacman -Syyuu --noconfirm \
	ffmpeg \
	libva \
	libva-utils \
	gstreamer \
	lame \
	libjxl && \
pacman -S --clean && \
rm -rf /var/cache/pacman/pkg/*


add_wants_niri() {
    sed -i "s/\[Unit\]/\[Unit\]\nWants=$1/" "/usr/lib/systemd/user/niri.service"
}
add_wants_niri cliphist.service
add_wants_niri plasma-polkit-agent.service
add_wants_niri swayidle.service
add_wants_niri udiskie.service
add_wants_niri xwayland-satellite.service
cat /usr/lib/systemd/user/niri.service

systemctl enable greetd
systemctl enable firewalld

# Sacrificed to the :steamhappy: emoji old god
pacman -Syyuu --noconfirm \
	noto-fonts \
	noto-fonts-emoji \
	noto-fonts-cjk \
	adwaita-fonts \
	opendesktop-fonts \
	gnu-free-fonts && \
pacman -S --clean && \
rm -rf /var/cache/pacman/pkg/*

cp -avf "/ctx/files"/. /

systemctl enable flatpak-preinstall.service
systemctl enable --global chezmoi-init.service
systemctl enable --global app-com.mitchellh.ghostty.service
systemctl enable --global chezmoi-update.timer
systemctl enable --global dms.service
systemctl enable --global cliphist.service
#systemctl enable --global gnome-keyring-daemon.socket
systemctl enable --global gnome-keyring-daemon.service
systemctl enable --global plasma-polkit-agent.service
systemctl enable --global swayidle.service
systemctl enable --global udiskie.service
systemctl enable --global xwayland-satellite.service
systemctl preset --global app-com.mitchellh.ghostty.service
systemctl preset --global chezmoi-init
systemctl preset --global chezmoi-update
systemctl preset --global cliphist
systemctl preset --global plasma-polkit-agent
systemctl preset --global swayidle
systemctl preset --global udiskie
systemctl preset --global xwayland-satellite

git clone "https://github.com/noctalia-dev/noctalia-shell.git" /usr/share/zirconium/noctalia-shell
cp /usr/share/zirconium/skel/Pictures/Wallpapers/mountains.png /usr/share/zirconium/noctalia-shell/Assets/Wallpaper/noctalia.png
git clone "https://github.com/zirconium-dev/zdots.git" /usr/share/zirconium/zdots
install -d /etc/niri/
cp -f /usr/share/zirconium/zdots/dot_config/niri/config.kdl /etc/niri/config.kdl
file /etc/niri/config.kdl | grep -F -e "empty" -v
stat /etc/niri/config.kdl

mkdir -p "/usr/share/fonts/Maple Mono"

MAPLE_TMPDIR="$(mktemp -d)"
trap 'rm -rf "${MAPLE_TMPDIR}"' EXIT

LATEST_RELEASE_FONT="$(curl "https://api.github.com/repos/subframe7536/maple-font/releases/latest" | jq '.assets[] | select(.name == "MapleMono-Variable.zip") | .browser_download_url' -rc)"
curl -fSsLo "${MAPLE_TMPDIR}/maple.zip" "${LATEST_RELEASE_FONT}"
unzip "${MAPLE_TMPDIR}/maple.zip" -d "/usr/share/fonts/Maple Mono"

echo 'source /usr/share/zirconium/shell/pure.bash' | tee -a "/etc/bashrc"
