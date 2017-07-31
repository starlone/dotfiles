sudo apt update
sudo apt full-upgrade

dependencies=`cat dependencies.txt`

sudo apt install $dependencies

dep_python=`cat dependencies-python.txt`

sudo easy_install -U $dep_python
