source functions.sh

create_user gitlab_ci "Gitlab CI"

sudo -u gitlab_ci -H sh -c 'printf "%b\n%b\n" "source /Users/gitlab_ci/.rvm/scripts/rvm" >> /Users/gitlab_ci/.profile'
sudo -u gitlab_ci -H -i source .profile

# CREATE POSTGRES USER AND DATABASE
createuser -S gitlab_ci
createdb -Ogitlab_ci gitlab_ci_production

# CLONE / INSTALL GITLAB CI
cd /Users/gitlab_ci
  sudo -u gitlab_ci -H git clone https://github.com/gitlabhq/gitlab-ci.git

  cd gitlab-ci
    sudo -u gitlab_ci -H mkdir -p tmp/pids
    sudo -u gitlab_ci -H bundle --without development test
    sudo -u gitlab_ci -H bundle exec rake db:setup RAILS_ENV=production