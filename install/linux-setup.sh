sudo apt-get install tmux
sudo apt-get install vim
sudo apt-get install curl
sudo apt-get install git
sudo apt-get install htop
sudo apt-get install silversearcher-ag
sudo apt-get install age

#install fuse & encfs
sudo apt-get install fuse
sudo apt-get install encfs

sudo apt install python3-virtualenv
pip install --upgrade pip

if ! command -v sops >/dev/null 2>&1; then
  echo "Install sops from https://github.com/getsops/sops/releases before using ep"
fi
