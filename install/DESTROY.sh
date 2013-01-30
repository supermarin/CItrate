# /bin/bash
#
# This script deletes the git and gitlab users

sudo dscl . delete /Groups/git

sudo dscl . delete /Users/git
sudo dscl . delete /Users/gitlab
sudo rm -rf /Users/git /Users/git
sudo rm -rf /Users/git /Users/gitlab

dropdb gitlabhq_production
dropuser gitlab

/tmp/gitlab_gitolite_admin_test

# brew uninstall postgres
# brew uninstall redis

