#!/bin/bash

set -eu

install_rpm() {
  RPM_INSTALLER=$(mktemp)
  wget "$1" -O ${RPM_INSTALLER}.rpm
  sudo zypper install -y ${RPM_INSTALLER}.rpm
  rm ${RPM_INSTALLER}
}

sudo zypper refresh && sudo zypper update

# Setup directories
mkdir ~/.backups
mkdir ~/.drivers
mkdir -p ~/.local/share/fonts
mkdir ~/.repos
mkdir ~/Projects

# Install fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz -O ~/.local/share/fonts/JetBrainsMono.tar.xz
tar -xf ~/.local/share/fonts/JetBrainsMono.tar.xz -C ~/.local/share/fonts
rm ~/.local/share/fonts/JetBrainsMono.tar.xz
fc-cache -f -v

sudo zypper install -y -t pattern devel_basis

# Install NVIDIA drivers
# https://en.opensuse.org/SDB:NVIDIA_drivers#Tumbleweed_/_Slowroll
sudo zypper addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed NVIDIA
sudo zypper install-new-recommends --repo NVIDIA

# Install packages
sudo zypper install -y \
  apache2-utils \
  bat \
  btop \
  ca-certificates \
  curl \
  fastfetch \
  yakuake \
  jose \
  keepassxc \
  mozilla-nss-tools \
  neovim \
  net-tools \
  smplayer \
  tmux \
  transmission \
  tree \
  virtualbox

# Install snap
# https://snapcraft.io/install/snap-store/opensuse
sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed/ snappy && \
sudo zypper --gpg-auto-import-keys refresh && \
sudo zypper dup --from snappy && \
sudo zypper install -y snapd && \
sudo systemctl enable --now snapd && \
sudo systemctl enable --now snapd.apparmor

# Install snap packages
sudo snap install \
  mysql-workbench-community \
  postman \
  smplayer

snap connect mysql-workbench-community:password-manager-service && \
snap connect mysql-workbench-community:ssh-keys

# Install poetry
curl -sSL https://install.python-poetry.org | python3 -

# Install Google Chrome
sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub
install_rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

# Install nvm (Node Version Manager)
# https://github.com/nvm-sh/nvm?tab=readme-ov-file#install--update-script
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 18
nvm install 20
nvm install 22

nvm alias default 20

nvm install-latest-npm
npm install -g npm-check-updates

# Install VSCode
# https://code.visualstudio.com/docs/setup/linux#_opensuse-and-slebased-distributions
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/zypp/repos.d/vscode.repo > /dev/null && \
sudo zypper refresh && \
sudo zypper install -y code

# Install Docker
# https://en.opensuse.org/Docker#with_Command_line
sudo zypper install -y docker docker-compose docker-compose-switch && \
sudo systemctl enable docker && \
sudo usermod -G docker -a $USER && \
newgrp docker && \
sudo systemctl restart docker && \
docker run --rm hello-world

# Install NVIDIA Container Toolkit
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-zypper
sudo zypper addrepo https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo && \
sudo zypper modifyrepo --enable nvidia-container-toolkit-experimental && \
sudo zypper --gpg-auto-import-keys install -y nvidia-container-toolkit && \
sudo nvidia-ctk runtime configure --runtime=docker && \
sudo systemctl restart docker

# Setup bat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# Setup git
git config --global user.name "Ionescu Liviu Cristian"
git config --global user.email "$(echo bGl2aXVAcHVycGxlY2F0LWxhYnMuY29t | base64 --decode)"
git config --global init.defaultBranch main
git config --global core.editor "code --wait --new-window"
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# Setup python
sudo ln -s /usr/bin/python3 /usr/bin/python

sudo reboot now
