#!/usr/bin/env bash

#@formatter:off
tmuxPaneOrTerminal(){
    if [[ $(hyprctl activewindow | grep tmux) ]]; then
        tmux new-window "$2";
    else
        if [[ $3 ]]; then
            $1 -c $3 -e $2;
        else
            $1 -e $2;
        fi
    fi
}

ramSize="4G"
cpuCores="2"

changeQemuRam(){
    echo -en $(
        for ((
            i = 1;
            i <= $(grep -E "MemTotal" /proc/meminfo | sed -e 's/[^0-9]//g') / ( 1024 * 1024);
            i++
        )) do
            echo -n $i "Gibibytes of RAM\n"
        done
    )\
    |
    fuzzel\
        --dmenu\
        --lines 7\
        --width 30\
        --tabs 4\
        --background \#110015e6\
        --text-color \#EE70FFff\
        --font 'Hack Nerd Font:size=15'\
        --border-color \#ff00ffff\
        --selection-color \#420080ff\
        --border-width 2\
        --border-radius 15\
    |
    sed 's/.$//'
}

declare -A menusAndCommands=(
    [" Arch linux installer; Terminal"]="\
        tmuxPaneOrTerminal foot \"
            qemu-system-x86_64\
                -enable-kvm\
                -cdrom /mnt/D/qemu/archlinux-2025.02.01-x86_64.iso\
                -drive file=/mnt/D/qemu/archLinuxImage\
                -boot order=d\
                -m $ramSize\
                -cpu host\
                -smp $cpuCores\
                -nographic\
        \"\
    "
    [" Arch linux installer; Gui"]="\
        qemu-system-x86_64\
            -enable-kvm\
            -cdrom /mnt/D/qemu/archlinux-2025.02.01-x86_64.iso\
            -drive file=/mnt/D/qemu/archLinuxImage\
            -boot order=d\
            -m $ramSize\
            -cpu host\
            -smp $cpuCores\
            -full-screen\
            -vga virtio\
            -display sdl,gl=on\
    "
    [" Arch linux; Terminal"]="\
        tmuxPaneOrTerminal foot \"
            qemu-system-x86_64\
                -enable-kvm\
                -drive file=/mnt/D/qemu/archLinuxImage\
                -m $ramSize\
                -cpu host\
                -smp $cpuCores\
                -nographic\
        \"\
    "
    [" Arch linux; Gui"]="\
        qemu-system-x86_64\
            -enable-kvm\
            -drive file=/mnt/D/qemu/archLinuxImage\
            -m $ramSize\
            -cpu host\
            -smp $cpuCores\
            -full-screen\
            -vga virtio\
            -display sdl,gl=on\
    "
    ["󱄅 NixOS installer; GUI"]="\
        qemu-system-x86_64\
            -enable-kvm\
            -cdrom /mnt/D/qemu/nixos-minimal-24.11.714127.f5a32fa27df9-x86_64-linux.iso\
            -drive file=/mnt/D/qemu/nixOS_image\
            -boot order=d\
            -m $ramSize\
            -cpu host\
            -smp $cpuCores\
            -full-screen\
            -vga virtio\
            -display sdl,gl=on\
        "
    ["󱄅 NixOS; GUI"]="\
        qemu-system-x86_64\
            -enable-kvm\
            -drive file=/mnt/D/qemu/nixOS_image\
            -m $ramSize\
            -cpu host\
            -smp $cpuCores\
            -full-screen\
            -vga virtio\
            -display sdl,gl=on\
        "
    [" Settings"]="\
        changeQemuRam
    "
)

chosen=$(echo -en $( for item in "${!menusAndCommands[@]}"; do echo -n $item "\n"; done)\
    |
    fuzzel\
        --dmenu\
        --lines 10\
        --width 35\
        --tabs 4\
        --background \#110015e6\
        --text-color \#EE70FFff\
        --font 'Hack Nerd Font:size=15'\
        --border-color \#ff00ffff\
        --selection-color \#420080ff\
        --border-width 2\
        --border-radius 15\
        --prompt "RAM: $ramSize CORES: $cpuCores => "\
    |
    sed 's/.$//'
)

echo \""$chosen"\"
if [[ "$chosen" != "" ]] then
    eval "${menusAndCommands["$chosen"]}"
fi
