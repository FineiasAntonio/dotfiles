#!/bin/bash

# Script de instalação de Dotfiles - Arch Linux (Otimizado para NVIDIA)
# Foco: Hyprland, Waybar, Kitty, Fish e Rofi (Catppuccin Mocha)

set -e

echo "🚀 Iniciando a instalação dos dotfiles e drivers NVIDIA..."

# 1. Instalação de drivers NVIDIA e dependências de plataforma
echo "📦 Instalando drivers NVIDIA e bibliotecas EGL..."
sudo pacman -S --needed --noconfirm \
    nvidia-open-dkms \
    nvidia-utils \
    lib32-nvidia-utils \
    nvidia-settings \
    linux-firmware-nvidia \
    egl-gbm \
    egl-wayland \
    egl-x11 \
    libvdpau \
    libxnvctrl

# 2. Instalação de dependências principais (Pacman)
echo "📦 Instalando pacotes do repositório oficial..."
sudo pacman -S --needed --noconfirm \
    hyprland hyprlock hypridle waybar kitty fish rofi-wayland \
    starship playerctl light brightnessctl nmcli networkmanager \
    grim slurp swww dunst pavucontrol ttf-jetbrains-mono-nerd \
    bluez bluez-utils cliphist wl-clipboard git base-devel

# 3. Configuração do Kernel para NVIDIA (Early Loading)
echo "⚙️ Configurando KMS para NVIDIA..."
# Adiciona os módulos necessários ao mkinitcpio para evitar problemas no Hyprland
if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
    sudo sed -i 's/MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
fi

# Adiciona parâmetro de kernel para DRM
if [ -d /etc/modprobe.d ]; then
    echo "options nvidia-drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf
fi

# 4. Instalação de um AUR Helper (yay)
if ! command -v yay &> /dev/null; then
    echo "🔍 Instalando yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm && cd -
fi

# 5. Instalação de dependências do AUR
echo "📦 Instalando pacotes do AUR..."
yay -S --noconfirm yazi hyprshot-git

# 6. Criando estrutura de diretórios e copiando arquivos
echo "📁 Organizando arquivos de configuração..."
mkdir -p ~/.config/{hypr,waybar,kitty,fish,rofi,dunst}
mkdir -p ~/.local/share/screenshots

# Assume que os arquivos estão na pasta atual
cp -rv hypr/* ~/.config/hypr/
cp -rv waybar/* ~/.config/waybar/
cp -rv kitty/* ~/.config/kitty/
cp -rv fish/* ~/.config/fish/
cp -rv rofi/* ~/.config/rofi/
cp -v starship.toml ~/.config/starship.toml

# 7. Configurando Fish e Fisher
echo "🐟 Configurando Fish Shell..."
if [ -f "/usr/bin/fish" ]; then
    sudo chsh -s /usr/bin/fish $USER
    # Instala o Fisher conforme suas funções
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fi

# 8. Permissões de execução para scripts Rofi e Waybar
echo "🔑 Ajustando permissões..."
find ~/.config/rofi/ -name "*.sh" -exec chmod +x {} +
chmod +x ~/.config/hypr/*.sh 2>/dev/null || true

echo "✅ Instalação concluída! REINICIE o computador para carregar os drivers NVIDIA."