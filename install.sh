#!/bin/bash

set -eo pipefail

pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

isPackageInstalled() {
	return $(dpkg-query --show $1 &> /dev/null)
}

ensurePackage() {
	echo "Ensure package $1"
	if ! isPackageInstalled $1; then
		echo "Install package $1"
		sudo apt-get install -y $1
	fi
}

ensurePPA() {
	echo "Ensure ppa:$1"
	if ! apt-cache policy | awk '/http/{print $2}' | grep -q $1; then
		sudo add-apt-repository -y ppa:$1
	fi
}

ensureDotfile() {
	echo "Ensure dotfile $1"
	if [[ -f "$HOME/$1" && ! -L "$HOME/$1" ]]; then
		echo "Moving file $HOME/$1 to $HOME/$1.bkp-$(date +%Y%m%d)"
		mv "$HOME/$1" "$HOME/$1.bkp-$(date +%Y%m%d)"
	fi
	if [[ -L "$HOME/$1" ]]; then
		if [[ "$(readlink "$HOME/$1")" == "$(pwd)/dotfiles/$1" ]]; then
			return
		fi
		ln -sf "$(pwd)/dotfiles/$1" "$HOME/$1"
		return
	fi
	ln -s "$(pwd)/dotfiles/$1" "$HOME/$1"
}

sudo apt-get update > /dev/null

ensurePPA regolith-linux/stable

ensurePackage apt-transport-https
ensurePackage compton
ensurePackage curl
ensurePackage fonts-jetbrains-mono
ensurePackage fonts-powerline
ensurePackage fzf
ensurePackage git
ensurePackage gnome-flashback
ensurePackage gnome-tweaks
ensurePackage htop
ensurePackage i3-gaps
ensurePackage libasound2-dev
ensurePackage make
ensurePackage nodejs
ensurePackage npm
ensurePackage openssh-server
ensurePackage pavucontrol
ensurePackage pip
ensurePackage rofi
ensurePackage telegram-desktop
ensurePackage terminator
ensurePackage vim
ensurePackage zsh

ensureDotfile .zshrc
ensureDotfile .vimrc
ensureDotfile .gitconfig
ensureDotfile .config/i3/config
ensureDotfile .config/i3/app-icons.json
ensureDotfile .config/terminator/config

echo "Ensure ~/bin"
mkdir -p $HOME/bin

echo "Ensure ~/.config/systemd/user"
mkdir -p $HOME/.config/systemd/user

echo "Ensure oh-my-zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended --skip-chsh
	sudo chsh -s /usr/bin/zsh
fi

echo "Ensure i3-gnome"
if ! command -v i3-gnome > /dev/null; then
	git clone https://github.com/i3-gnome/i3-gnome.git $HOME/projects/github.com/i3-gnome
	sudo make -C $HOME /projects/github.com/i3-gnome/ install
	gsettings set org.gnome.gnome-flashback desktop false
	gsettings set org.gnome.gnome-flashback root-background true
fi

echo "Ensure Google Chrome"
if ! command -v google-chrome-stable > /dev/null; then
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i google-chrome-stable_current_amd64.deb
	rm google-chrome-stable_current_amd64.deb
fi

echo "Ensure Signal"
if ! isPackageInstalled signal-desktop; then
	wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
	cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' \
		| sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
	sudo apt update && sudo apt install signal-desktop
fi

echo "Ensure power-menu"
if ! command -v rofi-power-menu > /dev/null; then
	git clone https://github.com/jluttine/rofi-power-menu.git $HOME/projects/github.com/rofi-power-menu
	cp rofi-power-menu/rofi-power-menu ~/bin/
fi

echo "Ensure latest kubectl"
k8sVersion=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
if [[ ! -f "$HOME/bin/kubectl-${k8sVersion}" ]]; then
	curl -LO "https://storage.googleapis.com/kubernetes-release/release/${k8sVersion}/bin/linux/amd64/kubectl"
	chmod +x kubectl
	mv kubectl "$HOME/bin/kubectl-$k8sVersion"
	ln -fs "$HOME/bin/kubectl-$k8sVersion" "$HOME/bin/kubectl"
fi

echo "Ensure docker-ce"
if ! isPackageInstalled docker-ce; then
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository \
		"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io
fi

echo "Ensure Spotify"
if ! isPackageInstalled spotify-client; then
	curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
	echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
	sudo apt-get update
	sudo apt-get install -y spotify-client
fi

echo "Ensure greenclip"
if ! command -v greenclip > /dev/null; then
	wget https://github.com/erebe/greenclip/releases/download/v4.2/greenclip -O $HOME/bin/greenclip
	chmod +x $HOME/bin/greenclip
	cat <<- EOF > $HOME/.config/systemd/user/greenclip.service
		[Unit]
		Description=Start greenclip daemon
		After=display-manager.service

		[Service]
		ExecStart=$HOME/bin/greenclip daemon
		Restart=always
		RestartSec=5

		[Install]
		WantedBy=default.target
	EOF
	systemctl --user enable greenclip
	systemctl --user start greenclip
fi

echo "Ensure i3-workspace-names-daemon"
if ! command -v i3-workspace-names-daemon > /dev/null; then
	sudo pip3 install i3-workspace-names-daemon
fi

echo "Ensure NOPASSWD in sudoers file"
if ! sudo grep -qE '%sudo.*NOPASSWD' /etc/sudoers; then
	sudo sed -i s'/^%sudo.*/%sudo   ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
fi

popd
