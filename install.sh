#!/bin/bash

set -eo pipefail

pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo apt-get update >/dev/null

isPackageInstalled() {
    return $(dpkg-query --show --showformat='${db:Status-Status}' $1 &>/dev/null)
}

ensurePPA() {
    echo "Ensuring ppa:$1"
    if ! apt-cache policy | awk '/http/{print $2}' | grep -q $1; then
        sudo add-apt-repository -y ppa:$1
    fi
}

ensurePPA regolith-linux/stable

for package in \
    apt-transport-https \
    compton \
    curl \
    fonts-jetbrains-mono \
    fonts-powerline \
    fzf \
    git \
    gnome-flashback \
    gnome-tweaks \
    htop \
    i3-gaps \
    libasound2-dev \
    make \
    nodejs \
    npm \
    openssh-server \
    pavucontrol \
    pip \
    rofi \
    telegram-desktop \
    terminator \
    vim \
    zsh; do
    echo "Ensuring package $package"
    if ! isPackageInstalled $package; then
        echo "Install $package via aptitude"
        sudo apt-get install -y $package
    fi
done

ensureDotfile() {
    echo "Ensuring dotfile $1"
    if [[ -f "$HOME/$1" && ! -L "$HOME/$1" ]]; then
        echo "Moving file $HOME/$1 to $HOME/$1.bkp-$(date +%Y%m%d)"
        mv "$HOME/$1" "$HOME/$1.bkp-$(date +%Y%m%d)"
    fi
    if [[ -L "$HOME/$1" ]]; then
        if [[ "$(readlink "$HOME/$1")" == "$(pwd)/$1" ]]; then
            return
        fi
        ln -sf "$(pwd)/$1" "$HOME/$1"
        return
    fi
    ln -s "$(pwd)/$1" "$HOME/$1"
}

ensureDotfile .zshrc
ensureDotfile .vimrc
ensureDotfile .gitconfig
ensureDotfile .config/i3/config
ensureDotfile .config/i3/app-icons.json
ensureDotfile .config/terminator/config

echo "Ensuring ~/bin"
mkdir -p $HOME/bin

echo "Ensuring Signal"
if ! isPackageInstalled signal-desktop; then
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
    cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
      sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
    sudo apt update && sudo apt install signal-desktop
fi

echo "Ensuring power-menu"
if ! command -v rofi-power-menu >/dev/null; then
    git clone https://github.com/jluttine/rofi-power-menu.git $HOME/projects/github.com/
    cp rofi-power-menu/rofi-power-menu ~/bin/
fi

echo "Ensuring latest kubectl"
k8sVersion=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
if [[ ! -f "$HOME/bin/kubectl-${k8sVersion}" ]]; then
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/${k8sVersion}/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl "$HOME/bin/kubectl-$k8sVersion"
    ln -fs "$HOME/bin/kubectl-$k8sVersion" "$HOME/bin/kubectl"
fi

echo "Ensuring docker-ce"
if ! isPackageInstalled docker-ce; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
fi

echo "Ensuring Spotify"
if ! isPackageInstalled spotify-client; then
    curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - 
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update
    sudo apt-get install -y spotify-client
fi

popd
