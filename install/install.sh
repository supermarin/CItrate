# /bin/bash
#
# Gitolite / GitlabHQ / GitlabCI installation script. OSX 10.8 and up.
# Author: Marin Usalj [mneorr@gmail.com]


# HELPER FUNCTIONS
# Should check for software existance before installing
source functions.sh

# # ROOT FUNCTIONS
# replace_home_dir_path() {
#   sudo perl -pi -e 's/^\/home/#\/home/g' /etc/auto_master # move this to functions
#   sudo automount -vc
#   sudo umount /home
#   sudo rmdir /home
#   sudo ln -s /Users /home
# }
# install_pip() {
#   if [[ `which pip` == "pip not found" ]]; then
#     sudo easy_install pip
#     echo "Installed pip."
#   fi
# }

# echo "Enabling SSH login..."
# sudo systemsetup -setremotelogin on 

# echo "Linking /Users to /home"
# replace_home_dir_path

# echo "Installing brew dependencies..."
# install_homebrew
# install_redis
# install_postgres
# install_mysql

# brew install git
# brew install qt
# brew install icu4c
# echo "Installed brew dependencies."

# # INSTALL RUBY - 1.9.3 TODO

# install_pip
# install_pygments
# install_bundler
# install_charlock_holmes

# # CONFIGURE GIT
# sudo -u gitlab -H -i git config --global user.name "GitLab"
# sudo -u gitlab -H -i git config --global user.email "gitlab@localhost"

# # INSTALL GITOLITE AND GITLAB
# sudo sh gitlab-install.sh

echo "Installing CI..."
sudo sh gitlabci-install.sh