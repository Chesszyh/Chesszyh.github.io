#!/bin/bash
# TODO Better error handling and logging 

yellow() { echo -e "\033[1;33m$*\033[0m"; }
green()  { echo -e "\033[1;32m$*\033[0m"; }
red()    { echo -e "\033[1;31m$*\033[0m"; }

set -e
trap 'red "An error occurred, script terminated."' ERR

install_zsh() {
    yellow "Installing zsh and oh-my-zsh..."
    sudo apt install -y zsh
    chsh -s "$(which zsh)"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # TODO zsh-plugins install failure before
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)/' ~/.zshrc
    green "zsh and oh-my-zsh installed successfully."
}

install_common_tools() {
    yellow "Installing common tools..."
    sudo apt install -y git curl wget build-essential
}

install_python() {
    yellow "Installing Python, pip, miniconda and uv..."
    sudo apt install -y python3 python3-pip
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    chmod +x ~/miniconda.sh
    bash ~/miniconda.sh -b -p "$HOME/miniconda"
    rm ~/miniconda.sh
    "$HOME/miniconda/bin/conda" init zsh
    curl -LsSf https://astral.sh/uv/install.sh | sh
    green "Python, pip, miniconda and uv installed successfully."
}

install_node() {
    yellow "Installing Node.js and npm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm install 22
    green "Node.js and npm installed successfully."
}

install_docker() {
    yellow "Installing Docker..."
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    green "Docker installed successfully."
}

install_custom_tools() {
    yellow "Installing custom tools..."
    CHOICES=$(whiptail --title "Custom Tools Installation Options" --checklist \
    "Select custom tools to install (space to select, Tab to switch, Enter to confirm):" 20 60 10 \
    "htop, btop, fastfetch, ncdu" "Interactive process viewer" ON \
    "tree, yazi, fzf, ripgrep, bat" "Better file management" ON \
    3>&1 1>&2 2>&3)

    for choice in $CHOICES; do
        case $choice in
            '"htop, btop, fastfetch, ncdu"') sudo apt install -y htop btop fastfetch ncdu ;;
            '"tree, yazi, fzf, ripgrep, bat"') sudo apt install -y tree yazi fzf ripgrep bat ;;
        esac
    done

    green "Custom tools installed successfully."
}

# Test mode using Docker
if [[ "$1" == "test" ]]; then
    SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd) || exit
    docker run -it \
        -v "$SCRIPT_DIR":/workspace \
        --name ubuntu-init-test \
        ubuntu:22.04 \
        bash -c "apt update && apt install -y sudo curl git wget build-essential whiptail && cd /workspace && bash ubuntu-server-init.sh"
    
    yellow "Enter the Docker container?"
    read -rp "(y/n): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        docker exec -it ubuntu-init-test zsh
    fi
    exit 0
fi

# SCRIPT STARTS HERE
sudo apt update

# whiptail multi-select menu
CHOICES=$(whiptail --title "Development Environment Installation Options" --checklist \
"Select components to install (space to select, Tab to switch, Enter to confirm):" 20 60 10 \
"zsh" "zsh/oh-my-zsh/zsh plugins" ON \
"common" "Common tools (git/curl/wget/build-essential)" ON \
"python" "Python/pip/Miniconda/uv" ON \
"node" "Node.js/npm/nvm" ON \
"docker" "Docker" ON \
"custom" "Custom tools (htop/btop/fastfetch/ncdu/tree)" ON \
3>&1 1>&2 2>&3)

for choice in $CHOICES; do
    case $choice in
        \"zsh\") install_zsh ;;
        \"common\") install_common_tools ;;
        \"python\") install_python ;;
        \"node\") install_node ;;
        \"docker\") install_docker ;;
    esac
done