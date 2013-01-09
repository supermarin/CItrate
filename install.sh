# /bin/bash
#
# Gitolite / GitlabHQ / GitlabCI installation script. OSX 10.8 and up.
# Author: Marin Usalj [mneorr@gmail.com]


# HELPER FUNCTIONS
# Should check for software existance before installing

install_homebrew() { # It checks for XCode and OSX versions
  if [[ `which homebrew` == "brew not found" ]]; then
    ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
    sudo chown -R `whoami` /usr/local
    echo "Installed homebrew."
  fi
}
install_pip() {
  if [[ `which pip` == "pip not found" ]]; then
    sudo easy_install pip
    echo "Installed pip."
  fi
}
install_bundler() {
  if [[ `gem list bundler` != *bundler* ]]; then
    sudo gem install bundler
  fi
}
install_charlock_holmes() {
  if [[ `gem list charlock_holmes` != *charlock_holmes* ]]; then
    sudo gem install charlock_holmes --version '0.6.8' --no-ri --no-rdoc
    echo "Installed charlock holmes."
  fi
}

# ENABLE REMOTE LOGIN
sudo systemsetup -setremotelogin on 

# INSTALL PROGRAMS
install_homebrew
brew install git
brew install mysql
brew install qt
brew install icu4c
brew install redis
echo "Installed brew packages."

pip install pygments

# INSTALL RUBY - 1.9.3 TODO
install_bundler
install_charlock_holmes

# CONFIGURE MYSQL - TODO: move to postgres
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
mysql.server start
/usr/local/opt/mysql/bin/mysqladmin -u root password 'PASSWORD'
echo "Configured MySql."

# INSTALL GITOLITE AND GITLAB
sudo bash gitlab-install.sh