#!/bin/bash
set  -eou pipefail

echo "Enter 'GIT_GLOBAL_USER_NAME'"
read GIT_GLOBAL_USER_NAME
echo "Enter 'GIT_GLOBAL_USER_EMAIL'"
read GIT_GLOBAL_USER_EMAIL

echo "Enter 'DOCKER_HUB_USERNAME'"
read DOCKER_HUB_USERNAME
echo "Enter 'DOCKER_HUB_PASSWORD'"
read -s DOCKER_HUB_PASSWORD

echo "================ Updating Repositories ==================="
sudo apt update

echo ""
echo "================ Installing & Configuring Git============="
DOWNLOAD_DIR=$PWD/apps

# create the download directory
mkdir -p $DOWNLOAD_DIR
# cleanup the download directory on exit
function cleanup() {
    rm -rf $DOWNLOAD_DIR
}
trap cleanup EXIT

pushd $DOWNLOAD_DIR

# install git
sudo apt install git git-gui xclip gnome-keyring -y

# configure git environment
git config --global user.name $GIT_GLOBAL_USER_NAME
git config --global user.email $GIT_GLOBAL_USER_EMAIL

echo "$GIT_GLOBAL_USER_NAME"
echo "$GIT_GLOBAL_USER_EMAIL"

echo "Generating new ssh-keys......"
ssh-keygen -t ed25519 -f "/root/.ssh/id_ed25519" -C "$GIT_GLOBAL_USER_EMAIL" -q -N "" || true

echo "Succesfully installed & configured git"

echo ""
echo "=============== Installing Zoom ===================="
wget https://zoom.us/client/latest/zoom_amd64.deb
sudo apt install ./zoom_amd64.deb -y

echo ""
echo "=============== Installing Slack ===================="
wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.12.2-amd64.deb
sudo apt install ./slack-desktop-4.12.2-amd64.deb -y

echo ""
echo "=============== Installing Discord ===================="
wget https://dl.discordapp.net/apps/linux/0.0.13/discord-0.0.13.deb
sudo apt install ./discord-0.0.13.deb -y

echo ""
echo "=============== Installing Google Chrome ===================="
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y


echo ""
echo "=============== Installing Brave Browser ===================="
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser

echo ""
echo "=============== Installing Visual Studio Code ===================="
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt install code


echo ""
echo "=============== Installing MegaSync Client ===================="
wget https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megasync-xUbuntu_20.04_amd64.deb
sudo apt install ./megasync-xUbuntu_20.04_amd64.deb -y

echo ""
echo "=============== Installing Mailspring ===================="
wget https://github.com/Foundry376/Mailspring/releases/download/1.8.0/mailspring-1.8.0-amd64.deb
sudo apt install ./mailspring-1.8.0-amd64.deb -y

echo ""
echo "=============== Installing Jetbrains Toolbox ===================="
wget https://download-cf.jetbrains.com/toolbox/jetbrains-toolbox-1.20.7940.tar.gz
sudo tar -xzf jetbrains-toolbox-1.20.7940.tar.gz -C /opt
/opt/jetbrains-toolbox-1.20.7940/jetbrains-toolbox


echo ""
echo "=============== Installing Go ===================="
sudo curl -fsSL https://raw.githubusercontent.com/udhos/update-golang/master/update-golang.sh | bash
$(which go) version || true

echo ""
echo "=============== Installing Docker ===================="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
# verify that docker has been installed already
sudo docker run hello-world
sudo usermod -aG docker $(whoami)
# login into dockerhub
sudo docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD

echo ""
echo "=============== Installing kubectl ===================="
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl
# verify that kubectl has been installed succesfully
kubectl version

echo ""
echo "=============== Installing Kind ===================="
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind
# verify kind has been installed successfully
kind version

echo ""
echo "=============== Installing Helm ===================="
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update
sudo apt install -y helm
# verify helm has been installed successfully
helm version

echo ""
echo "=============== Installing zsh ===================="
# install zsh
sudo apt install -y zsh
# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# install MesloLGS NF Regular.ttf
curl -fsSL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
sudo mv ./MesloLGS%20NF%20Regular.ttf /usr/local/share/fonts/
# install powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# install syntax highlighting plugin
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# install auto-suggestion plugin
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

