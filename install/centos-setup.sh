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

case $(ask_install "tmux") in
  yes )
    sudo yum install tmux
    echo "done";;
  no )echo "skipping";;
  * ) echo "invalid... skipping";;
esac

case $(ask_install "htop") in
  yes )
    sudo yum install htop
    echo "done";;
  no )echo "skipping";;
  * ) echo "invalid... skipping";;
esac
