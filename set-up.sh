#!/bin/bash

# HyprV3 By SolDoesTech - https://www.youtube.com/@SolDoesTech
# License..? - You may copy, edit and ditribute this script any way you like, enjoy! :)

# The follwoing will attempt to install all needed packages to run Hyprland
# This is a quick and dirty script there are some error checking
# This script is meant to run on a clean fresh Arch install on physical hardware
#
# Below is a list of the packages that would be installed
#
# Nvidia GPU only
# linux-headers: Headers and scripts for building modules for the Linux kernel
# nvidia-dkms: NVIDIA drivers - module sources
# qt5-wayland: Provides APIs for Wayland
# qt5ct: Qt5 Configuration Utility
# libva: Video Acceleration (VA) API for Linux
# libva-nvidia-driver-git [AUR]: VA-API implementation that uses NVDEC as a backend (git version)

# hyprland: a highly customizable dynamic tiling Wayland compositor
# kitty: A modern, hackable, featureful, OpenGL-based terminal emulator
# jq: Command-line JSON processor
# mako: Lightweight notification daemon for Wayland
# waybar-hyprland [AUR]: Highly customizable Wayland bar for Sway and Wlroots based compositors, with workspaces support for Hyprland
# swww [AUR]: Efficient animated wallpaper daemon for wayland, controlled at runtime.
# swaylock-effects [AUR]: A fancier screen locker for Wayland.
# wofi: launcher for wlroots-based wayland compositors
# wlogout [AUR]: Logout menu for wayland
# xdg-desktop-portal-hyprland: xdg-desktop-portal backend for hyprland
# swappy: A Wayland native snapshot editing tool
# grim: Screenshot utility for Wayland
# slurp: Select a region in a Wayland compositor
# thunar: Modern, fast and easy-to-use file manager for Xfce
# polkit-gnome: Legacy polkit authentication agent for GNOME
# python-requests: Python HTTP for Humans
# pamixer: Pulseaudio command-line mixer like amixer
# pavucontrol: PulseAudio Volume Control
# network-manager-applet: Applet for managing network connection
# gvfs: Virtual filesystem implementation for GIO
# thunar-archive-plugin: Adds archive operations to the Thunar file context menus
# file-roller: Create and modify archives
# btop: A monitor of system resources, bpytop ported to C++
# pacman-contrib: Contributed scripts and tools for pacman systems
# starship: The cross-shell prompt for astronauts
# ttf-jetbrains-mono-nerd: Patched font JetBrains Mono from nerd fonts library
# noto-fonts-emoji: Google Noto emoji fonts
# lxappearance: Feature-rich GTK+ theme switcher of the LXDE Desktop

# set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"
INSTLOG="install.log"

# clear the screen
clear

# set some expectations for the user
echo -e "$CNT - You are about to execute a script that would attempt to setup Hyprland.
Please note that Hyprland is still in Beta."
sleep 1

# attempt to discover if this is a VM or not
echo -e "$CNT - Checking for Physical or VM..."
ISVM=$(hostnamectl | grep Chassis)
echo -e "Using $ISVM"
if [[ $ISVM == *"vm"* ]]; then
    echo -e "$CWR - Please note that VMs are not fully supported and if you try to run this on
    a Virtual Machine there is a high chance this will fail."
    sleep 1
fi

# let the user know that we will use sudo
echo -e "$CNT - This script will run some commands that require sudo. You will be prompted to enter your password.
If you are worried about entering your password then you may want to review the content of the script."
sleep 1

# give the user an option to exit out
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to continue with the install (y,n) ' CONTINST
if [[ $CONTINST == "Y" || $CONTINST == "y" ]]; then
    echo -e "$CNT - Setup starting..."
else
    echo -e "$CNT - This script would now exit, no changes were made to your system."
    exit
fi

# Ask if the use has an NVIDIA GPU
read -rep $'[\e[1;33mACTION\e[0m] - Do you have an Nvidia GPU? (y,n) ' ISNVIDIA
if [[ $ISNVIDIA == "Y" || $ISNVIDIA == "y" ]]; then
    echo -e "$CWR - Please note that support for Nvidia GPUs is limited.
    This script would attempt to set things up the best way it can.
    If you do end up with a black screen after trying to login then the GPU is likely the issue."
    
    ISNVIDIA=true
else
    ISNVIDIA=false
fi

### Disable wifi powersave mode ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to disable WiFi powersave? (y,n) ' WIFI
if [[ $WIFI == "Y" || $WIFI == "y" ]]; then
    LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
    echo -e "$CNT - The following file has been created $LOC."
    echo -e "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC &>> $INSTLOG
    echo -e "\n"
    echo -e "$CNT - Restarting NetworkManager service..."
    sleep 1
    sudo systemctl restart NetworkManager &>> $INSTLOG
    sleep 3
fi

#### Check for package manager ####
ISYAY=/sbin/yay
if [ -f "$ISYAY" ]; then 
    echo -e "$COK - yay was located, moving on."
else 
    echo -e "$CWR - Yay was NOT located.. yay is (still) required"
    read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install yay (y,n) ' INSTYAY
    if [[ $INSTYAY == "Y" || $INSTYAY == "y" ]]; then
        git clone https://aur.archlinux.org/yay-git.git &>> $INSTLOG
        cd yay-git
        makepkg -si --noconfirm &>> ../$INSTLOG
        cd ..
    else
        echo -e "$CER - Yay is (still) required for this script, now exiting"
        exit
    fi
    # update the yay database
    echo -e "$CNT - Updating the yay database..."
    yay -Suy --noconfirm &>> $INSTLOG
fi

# function that will test for a package and if not found it will attempt to install it
install_software() {
    # First lets see if the package is there
    if yay -Q $1 &>> /dev/null ; then
        echo -e "$COK - $1 is already installed."
    else
        # no package found so installing
        echo -e "$CNT - Now installing $1 ..."
        yay -S --noconfirm $1 &>> $INSTLOG
        # test to make sure package installed
        if yay -Q $1 &>> /dev/null ; then
            echo -e "\e[1A\e[K$COK - $1 was installed."
        else
            # if this is hit then a package is missing, exit to review log
            echo -e "\e[1A\e[K$CER - $1 install had failed, please check the install.log"
            exit
        fi
    fi
}

### Install all of the above pacakges ####
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install the packages? (y,n) ' INST
if [[ $INST == "Y" || $INST == "y" ]]; then
    # Setup Nvidia if it was selected
    if [[ "$ISNVIDIA" == true ]]; then
        echo -e "$CNT - Nvidia setup stage, this may take a while..."
        for SOFTWR in linux-headers nvidia-dkms qt5-wayland qt5ct libva libva-nvidia-driver-git
        do
            install_software $SOFTWR
        done
    
        # update config
        sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
        echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf &>> $INSTLOG
    fi

    # Stage 1 - main components
    echo -e "$CNT - Stage 1 - Installing main components, this may take a while..."
    for SOFTWR in hyprland kitty jq mako waybar-hyprland-git swww swaylock-effects wofi wlogout xdg-desktop-portal-hyprland swappy grim slurp thunar
    do
           install_software $SOFTWR 
    done

    # Stage 2 - more tools
    echo -e "$CNT - Stage 2 - Installing additional tools and utilities, this may take a while..."
    for SOFTWR in polkit-gnome python-requests pamixer pavucontrol network-manager-applet gvfs thunar-archive-plugin file-roller btop pacman-contrib
    do
        install_software $SOFTWR
    done

    # Stage 3 - some visual tools
    echo -e "$CNT - Stage 3 - Installing theme and visual related tools and utilities, this may take a while..."
    for SOFTWR in starship ttf-jetbrains-mono-nerd noto-fonts-emoji lxappearance lightdm lightdm-gtk-greeter 
    do
        install_software $SOFTWR
    done


    # Enable the sddm login manager service
    echo -e "$CNT - Enabling the Lightdm Service..."
    sudo systemctl enable lightdm &>> $INSTLOG
    sleep 2
    
    # Clean out other portals
    echo -e "$CNT - Cleaning out conflicting xdg portals..."
    yay -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk &>> $INSTLOG
fi

### Copy Config Files ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to copy config files? (y,n) ' CFG
if [[ $CFG == "Y" || $CFG == "y" ]]; then
    echo -e "$CNT - Copying config files..."

    # copy the HyprV directory
    cp -R HyprV ~/.config/

    # Setup each appliaction
    # check for existing config folders and backup 
    for DIR in hypr kitty mako swaylock waybar wlogout wofi 
    do 
        DIRPATH=~/.config/$DIR
        if [ -d "$DIRPATH" ]; then 
            echo -e "$CAT - Config for $DIR located, backing up."
            mv $DIRPATH $DIRPATH-back &>> $INSTLOG
            echo -e "$COK - Backed up $DIR to $DIRPATH-back."
        fi

        # make new empty folders
        mkdir -p $DIRPATH &>> $INSTLOG
    done

    # link up the config files
    echo -e "$CNT - Setting up the new config..." 
    cp ~/.config/HyprV/hypr/* ~/.config/hypr/
    ln -sf ~/.config/HyprV/kitty/kitty.conf ~/.config/kitty/kitty.conf
    ln -sf ~/.config/HyprV/mako/conf/config-dark ~/.config/mako/config
    ln -sf ~/.config/HyprV/swaylock/config ~/.config/swaylock/config
    ln -sf ~/.config/HyprV/waybar/conf/v3-config.jsonc ~/.config/waybar/config.jsonc
    ln -sf ~/.config/HyprV/waybar/style/v3-style-dark.css ~/.config/waybar/style.css
    ln -sf ~/.config/HyprV/wlogout/layout ~/.config/wlogout/layout
    ln -sf ~/.config/HyprV/wofi/config ~/.config/wofi/config
    ln -sf ~/.config/HyprV/wofi/style/v3-style-dark.css ~/.config/wofi/style.css
    
    # stage the .desktop file
    sudo cp Extras/hyprland.desktop /usr/share/wayland-sessions/
    
    if [[ "$ISNVIDIA" == true ]]; then
        # setup nvidia startup file
        cp Extras/start-hypr-nvidia ~/.start-hypr-nvidia
        sudo sed -i 's/Exec=Hyprland/Exec=\/home\/'$USER'\/.start-hypr-nvidia/' /usr/share/wayland-sessions/hyprland.desktop
    else
        # setup non nvidia startup file
        cp Extras/start-hypr-amd ~/.start-hypr-amd
        sudo sed -i 's/Exec=Hyprland/Exec=\/home\/'$USER'\/.start-hypr-amd/' /usr/share/wayland-sessions/hyprland.desktop
    fi

    # setup the first look and feel as dark
    xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
    xfconf-query -c xsettings -p /Net/IconThemeName -s "Adwaita-dark"
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    gsettings set org.gnome.desktop.interface icon-theme "Adwaita-dark"
    cp -f ~/.config/HyprV/backgrounds/v3-background-dark.jpg /usr/share/lightdm/themes/chrizelle/wallpaper.jpg
fi


### Script is done ###
echo -e "$CNT - Script had completed!"
if [[ "$ISNVIDIA" == true ]]; then 
    echo -e "$CAT - Since we attempted to setup Nvidia the script will now end and you should reboot.
    type 'reboot' at the prompt and hit Enter when ready."
    exit
fi

read -rep $'[\e[1;33mACTION\e[0m] - Would you like to start Hyprland now? (y,n) ' HYP
if [[ $HYP == "Y" || $HYP == "y" ]]; then
    exec sudo systemctl start sddm &>> $INSTLOG
else
    exit
fi
