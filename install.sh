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
install_pygments() {
  if [[ `which pygmentize` == "pygmentize not found" ]]; then
    pip install pygments
    echo "Installed pygments."
  fi
}
install_bundler() {
  if [[ `gem list bundler` != *bundler* ]]; then
    sudo gem install bundler
  fi
}
install_charlock_holmes() {
  if [[ `gem list charlock_holmes` != *charlock_holmes* ]]; then
    sudo gem install charlock_holmes --version '0.6.9' --no-ri --no-rdoc
    echo "Installed charlock holmes."
  fi
}
install_postgres() { # WARNING!!! THIS COULD ERASE THE DATA!!!!
  if [[ `brew install postgres` != *Error:* ]]; then
    initdb /usr/local/var/postgres -E utf8 # Initialize 
    ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents # Make it load on every boot
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist # Load it now
    echo "Installed Postgres"
  else
    echo "Postgres was already installed"
  fi
}
install_redis() {
  if [[ `which redis-server` == "redis-server not found" ]]; then
    brew install redis
    ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
    echo "Installed Redis."
  fi
}

# ENABLE REMOTE LOGIN
sudo systemsetup -setremotelogin on 

# INSTALL PROGRAMS
install_homebrew
install_redis
install_postgres

brew install git
brew install qt
brew install icu4c
echo "Installed brew packages."

# INSTALL RUBY - 1.9.3 TODO

install_pip
install_pygments
install_bundler
install_charlock_holmes

# INSTALL GITOLITE AND GITLAB
sudo sh gitlab-install.sh

# CONFIGURE GIT
sudo -u gitlab -H git config --global user.name "GitLab"
sudo -u gitlab -H git config --global user.email "gitlab@localhost"

