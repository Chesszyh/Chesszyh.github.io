#!/bin/bash 
# I assume that you have already installed arch linux with hyprland config!

# Basic tools
sudo pacman -S base-devel git curl wget neovim

# C++
sudo pacman -S gcc gdb cmake ninja clang lldb

# Python
sudo pacman -S python python-pip python-virtualenv python-pipenv uv
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
chmod +x ~/miniconda.sh
bash ~/miniconda.sh -b -p "$HOME/miniconda"
rm ~/miniconda.sh
"$HOME/miniconda/bin/conda" init zsh
curl -LsSf https://astral.sh/uv/install.sh | sh

# Node.js
sudo pacman -S nodejs npm nvm pnpm yarn

# Docker
sudo pacman -S docker docker-compose
sudo usermod -aG docker "$USER"

# chrome
yay -S google-chrome

# Regular tools
sudo pacman -S neovim eza glow ripgrep fd bat ncdu

