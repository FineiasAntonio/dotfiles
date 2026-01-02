#!/bin/bash

# Diretório base dos dotfiles
DOTFILES_DIR=$(pwd)

# Função para instalar pacotes
instalar_pacote() {
    local pacote=$1
    echo "Instalando: $pacote"
    if command -v yay &> /dev/null; then
        yay -S --noconfirm --needed $pacote
    else
        sudo pacman -S --noconfirm --needed $pacote
    fi
}

# Nova Função: Instalação e Configuração NVIDIA
configurar_nvidia() {
    echo "🚀 Instalando drivers NVIDIA..."
    # Instala drivers e suporte EGL
    instalar_pacote "nvidia nvidia-utils lib32-nvidia-utils nvidia-settings linux-lts-headers egl-gbm egl-wayland"

    echo "⚙️ Configurando KMS e DRM..."
    
    # 1. Early Loading no mkinitcpio
    if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
        sudo sed -i 's/MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
        sudo mkinitcpio -P
    fi

    # 2. Configuração via Modprobe
    if [ ! -f /etc/modprobe.d/nvidia.conf ]; then
        echo "options nvidia-drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf
    fi

    # 3. Configuração via GRUB (Garantia extra)
    echo "🔧 Adicionando nvidia-drm.modeset=1 ao GRUB..."
    if grep -q "GRUB_CMDLINE_LINUX_DEFAULT=" /etc/default/grub; then
        # Verifica se o parâmetro já existe para não duplicar
        if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 nvidia-drm.fbdev=1/' /etc/default/grub
            sudo grub-mkconfig -o /boot/grub/grub.cfg
            echo "✅ GRUB atualizado."
        else
            echo "ℹ️ Parâmetro já existe no GRUB."
        fi
    fi
    
    whiptail --msgbox "NVIDIA configurada no Kernel, Modprobe e GRUB. Reinicie o sistema." 10 50
}

criar_links() {
    echo "Criando links simbólicos..."
    local pastas=("hypr" "waybar" "kitty" "fish" "rofi" "swaync" "btop")
    mkdir -p ~/.config
    for pasta in "${pastas[@]}"; do
        if [ -d "$DOTFILES_DIR/$pasta" ]; then
            rm -rf "$HOME/.config/$pasta"
            ln -s "$DOTFILES_DIR/$pasta" "$HOME/.config/$pasta"
        fi
    done
    [ -f "$DOTFILES_DIR/starship.toml" ] && ln -sf "$DOTFILES_DIR/starship.toml" ~/.config/starship.toml
}

while true; do
    CHOICE=$(whiptail --title "Arch Linux - Super Instalador" --menu \
    "Escolha uma opção:" 22 75 12 \
    "1" "IntelliJ IDEA Ultimate (AUR)" \
    "2" "IntelliJ IDEA Community" \
    "3" "VSCode (Code-OSS)" \
    "4" "Node.js + Angular CLI" \
    "5" "JDK 17 (OpenJDK)" \
    "6" "Drivers NVIDIA (Configuração de Kernel)" \
    "7" "Ambiente Hyprland (Setup + Links)" \
    "8" "Sair" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) instalar_pacote "intellij-idea-ultimate-edition" ;;
        2) instalar_pacote "intellij-idea-community-edition" ;;
        3) instalar_pacote "code" ;;
        4) instalar_pacote "nodejs npm"; sudo npm install -g @angular/cli ;;
        5) instalar_pacote "jdk17-openjdk" ;;
        6) configurar_nvidia ;;
        7) 
            instalar_pacote "hyprland hyprpaper hyprlock hypridle swaync rofi-wayland kitty fish starship waybar fastfetch btop"
            criar_links
            find ~/.config/rofi/ -name "*.sh" -exec chmod +x {} +
            ;;
        8) exit 0 ;;
        *) exit 0 ;;
    esac

    [ $? -eq 0 ] && whiptail --msgbox "Sucesso!" 8 45 || whiptail --msgbox "Erro na operação." 8 45
done
