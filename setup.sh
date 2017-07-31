sudo apt update
sudo apt full-upgrade

dependencies=`cat dependencies.txt`

sudo apt install $dependencies
