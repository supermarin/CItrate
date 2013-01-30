create_group() {
  dscl . -create /Groups/git
  dscl . -append /Groups/git gid 789
  sudo sh -c 'printf "%b\n" "git:*:789:git,gitlab" >> /etc/group'
} 
# create_user "USERNAME" "REAL NAME"
create_user() {
  dscl . -create /Users/$1
  # dscl . -passwd /Users/$1 PASSWORD
  dscl . -append /Users/$1 UserShell /bin/bash
  dscl . -append /Users/$1 RealName $2
  dscl . -append /Users/$1 UniqueID $RANDOM
  dscl . -append /Users/$1 PrimaryGroupID 20 # staff
  dscl . -append /Groups/git GroupMembership $1
  mkdir -p /Users/$1
  chown -R $1:git /Users/$1
  dscl . -append /Users/$1 NFSHomeDirectory /Users/$1
}
install_homebrew() { # It checks for XCode and OSX versions
  if [[ `which homebrew` == "brew not found" ]]; then
    ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
    sudo chown -R `whoami` /usr/local
    echo "export PATH=/usr/local/bin:$PATH" >> ~/.zshenv
    echo "export PATH=/usr/local/bin:$PATH" >> ~/.bashrc #for users without zsh
    echo "Installed homebrew."
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
install_postgres() {
  if [[ `brew install postgres` != *'already installed'* ]]; then
    initdb /usr/local/var/postgres -E utf8 # Initialize 
    ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents # Make it load on every boot
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist # Load it now
    createuser -s root # not sure if this is dangerous
    echo "Installed Postgres"
  else
    echo "Postgres was already installed"
  fi
}
install_mysql() {
  output=`brew install mysql`
  if [[ $output == *'already installed'* ]]; then
    echo "MySQL was already installed"
  else
    if [[ $output == *'Could not link mysql'* ]]; then
      `brew link --overwrite mysql`
    fi
    mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
    ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents # Make it load on every boot
    mysql.server start # Load it now
    echo "Installed MySQL. Don't forget to set your root password!!! You can do it with following commands:

    /usr/local/opt/mysql/bin/mysqladmin -u root password 'new-password'
    /usr/local/opt/mysql/bin/mysqladmin -u root -h $(hostname) password 'new-password'"
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