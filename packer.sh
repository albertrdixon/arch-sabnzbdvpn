#!/bin/bash

# exit script if return code != 0
set -e

# define pacman packages
pacman_packages="base-devel"

# define packer packages
packer_packages="sabnzbd"

# install required pre-reqs for makepkg
pacman -S --needed $pacman_packages --noconfirm

# create "makepkg-user" user for makepkg
useradd -m -s /bin/bash makepkg-user
echo -e "makepkg-password\nmakepkg-password" | passwd makepkg-user
echo "makepkg-user ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)

# download packer
curl -o /home/makepkg-user/packer.tar.gz https://aur.archlinux.org/cgit/aur.git/snapshot/packer.tar.gz
cd /home/makepkg-user
su -c "tar -xvf packer.tar.gz" - makepkg-user

# install packer
su -c "cd /home/makepkg-user/packer && makepkg -s --noconfirm --needed" - makepkg-user
pacman -U /home/makepkg-user/packer/packer*.tar.xz --noconfirm

# install par2 multithreaded first using packer (cannot bundle with sabnzbd as order means aor single threaded par2 gets installed first)
su -c "packer -S par2cmdline-tbb --noconfirm" - makepkg-user

# install app using packer
su -c "packer -S $packer_packages --noconfirm" - makepkg-user

# remove base devel tools and packer
pacman -Ru base-devel git --noconfirm

# re-install sed and grep as these packages are removed when uninstalling base-devel
pacman -S --needed sed grep --noconfirm

# delete makepkg-user account
userdel -r makepkg-user
