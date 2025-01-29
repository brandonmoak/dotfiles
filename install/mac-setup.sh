#! /bin/bash

function ask_install () {
  read -p "install $1 (yes/no) " yesno
  echo "$yesno"
}


#case $(ask_install "test") in
#  yes )
#    # install commands here
#    echo "done";;
#  no )echo "skipping";;
#  * ) echo "invalid... skipping";;
#esac


# install brew
case $(ask_install "brew") in
  yes )
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    export PATH=/opt/homebrew/bin:$PATH
    echo 'PATH="/opt/homebrew/bin:$PATH"' >> ~/.bashrc
    echo 'PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
    echo "done";;
  no )echo "skipping";;
  * ) echo "invalid... skipping";;
esac


case $(ask_install "upgrade bash") in
  yes )
     brew install bash
    /opt/homebrew/bin/bash --version
    sudo sh -c 'echo /opt/homebrew/bin/bash >> /etc/shells'
    chsh -s /opt/homebrew/bin/bash
    echo "done";;
  no )echo "skipping";;
  * ) echo "invalid... skipping";;
esac

case $(ask_install "git completion") in
  yes )
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
    chmod +x ~/.git-completion.bash
    echo "done";;
  no )echo "skipping";;
  * ) echo "invalid... skipping";;
esac

brew install ripgrep
