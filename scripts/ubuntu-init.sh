#!/bin/bash
# TODO Better error handling and logging 

yellow() { echo -e "\033[1;33m$*\033[0m"; } # Normal process
green()  { echo -e "\033[1;32m$*\033[0m"; } # Success message
red()    { echo -e "\033[1;31m$*\033[0m"; } # Error message
blue()   { echo -e "\033[1;34m$*\033[0m"; } # NOTE Info message

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

install_cpp() {
    yellow "Installing C++ development tools(cmake, clang, gdb...)"
    sudo apt install cmake clang gdb
    sudo apt-get install clangd
    sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-18 100 # 设置clangd为默认
    ln -sf /build/compile_commands.json .
    green "C++ development tools installed successfully."
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

install_rust(){
    yellow "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source "$HOME/.cargo/env"
    rustup component add rust-analyzer
    green "Rust installed successfully."
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

install_yazi(){
    yellow "Installing yazi with optional dependencies..."
    yellow "You can choose to skip some optional dependencies if you don't need them."
    sudo apt install ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick
    blue "yazi doesn't have a official deb release, so you need to build from source or install from snap."
    
    # NOTE Building process may be killed in low memory environment
    yellow "Installing from snap(1), build from source(2,need rust) or cancel(3)"
    read -rp "Enter your choice [1-3]: " choice
    if [ "$choice" -eq 1 ]; then
        sudo snap install yazi --classic
    elif [ "$choice" -eq 2 ]; then
        git clone --depth=1 https://github.com/sxyazi/yazi.git
        cd yazi
        # Check if cargo is installed
        if ! command -v cargo &> /dev/null; then
        install_rust
        fi
        cargo build --release --locked
        mv target/release/yazi target/release/ya /usr/local/bin/
    elif [ "$choice" -eq 3 ]; then
        yellow "Installation cancelled."
    fi
}

install_custom_tools() {
    yellow "Installing custom tools..."
    CHOICES=$(whiptail --title "Custom Tools Installation Options" --checklist \
    "Select custom tools to install (space to select, Tab to switch, Enter to confirm):" 20 60 10 \
    "htop" "Interactive process viewer" ON \
    "btop" "All-in-one resource monitor" ON \
    "fastfetch" "Fast system information display tool" ON \
    "ncdu" "Disk usage analyzer" ON \
    "tree" "Directory tree viewer" ON \
    "bat" "Cat clone with syntax highlighting" ON \
    "yazi" "Command-line file manager" ON \
    3>&1 1>&2 2>&3)

    if [ $? -ne 0 ] || [ -z "$CHOICES" ]; then
        yellow "No tools selected or menu cancelled."
        return
    fi

    echo "Selected choices: $CHOICES"

    # 将 whiptail 返回的带引号字段解析为数组（保留每个选项里的空格）
    # TODO fix this
    parsed_choices=("$CHOICES")

    for choice in "${parsed_choices[@]}"; do
        case "$choice" in
            \"htop\" ) sudo apt install -y htop ;;
            \"btop\" ) sudo apt install -y btop ;;
            \"fastfetch\" ) sudo apt install -y fastfetch ;;
            \"ncdu\" ) sudo apt install -y ncdu ;;
            \"tree\" ) sudo apt install -y tree ;;
            \"bat\" ) sudo apt install -y bat ;;
            \"yazi\" ) install_yazi ;;
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
        bash -c "apt update && apt install -y sudo curl git wget build-essential whiptail && cd /workspace && bash ubuntu-init.sh"
    
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
"zsh" "zsh/oh-my-zsh/zsh plugins" OFF \
"common" "Common tools (git/curl/wget/build-essential)" OFF \
"cpp" "C++ (cmake/clang/gdb)" OFF \
"python" "Python/pip/Miniconda/uv" OFF \
"node" "Node.js/npm/nvm" OFF \
"rust" "Rust/rust-analyzer" OFF \
"docker" "Docker" OFF \
"custom" "Custom tools" ON \
3>&1 1>&2 2>&3)

for choice in $CHOICES; do
    case $choice in
        \"zsh\") install_zsh ;;
        \"common\") install_common_tools ;;
        \"cpp\") install_cpp ;;
        \"python\") install_python ;;
        \"node\") install_node ;;
        \"docker\") install_docker ;;
        \"custom\") install_custom_tools ;;
    esac
done