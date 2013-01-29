# /bin/bash
#
# Gitolite / GitlabHQ / GitlabCI installation script. OSX 10.8 and up.
# Author: Marin Usalj [mneorr@gmail.com]


# HELPER FUNCTIONS
# Should check for software existance before installing

source functions.sh

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

sudo install_pip
install_pygments
install_bundler
install_charlock_holmes

# INSTALL GITOLITE AND GITLAB
sudo sh gitlab-install.sh

# CONFIGURE GIT
sudo -u gitlab -H -i git config --global user.name "GitLab"
sudo -u gitlab -H -i git config --global user.email "gitlab@localhost"

# TEST PRODUCTION:
cd /Users/gitlab/gitlab
sudo -u gitlab -H bundle exec rake gitlab:check RAILS_ENV=production