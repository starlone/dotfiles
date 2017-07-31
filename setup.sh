sudo apt update
sudo apt full-upgrade

# ----------
# Shell
# ----------
dependencies=`cat dependencies.txt`
sudo apt install -y $dependencies

echo '
----------
 Python
----------
'
dep_python=`cat dependencies-python.txt`
sudo easy_install -U $dep_python

echo '
----------
 NodeJS
----------
'
sudo npm install -g npm n yarn
sudo n latest
dep_nodejs=`cat dependencies-nodejs.txt`
sudo npm install -g $dep_nodejs
