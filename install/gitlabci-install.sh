source functions.sh

echo "Creating user Gitlab CI"
create_user gitlab_ci "Gitlab CI"

# sudo -u gitlab_ci -H sh -c 'printf "%b\n%b\n" "source /Users/gitlab_ci/.rvm/scripts/rvm" >> /Users/gitlab_ci/.profile'
# sudo -u gitlab_ci -H -i source .profile

# CREATE POSTGRES USER AND DATABASE
createuser -d gitlab_ci
createdb -Ogitlab_ci gitlab_ci_production
echo "Created database."

# CLONE / INSTALL GITLAB CI
cd /Users/gitlab_ci
  sudo -u gitlab_ci -H git clone https://github.com/mneorr/gitlab-ci.git
  
  cd gitlab-ci
    sudo -u gitlab_ci -H git checkout 2-0-stable
    # Create a tmp directory inside application
    sudo -u gitlab_ci -H mkdir -p tmp/pids
    # Install dependencies
    sudo -u gitlab_ci -H bundle install --deployment --without development test postgresql
    # Copy postgres db config
    # make sure to update username/password in config/database.yml
    sudo -u gitlab_ci -H cp config/database.yml.mysql config/database.yml
    # Setup DB
    sudo -u gitlab_ci -H bundle exec rake db:setup RAILS_ENV=production
    # Setup scedules 
    sudo -u gitlab_ci -H bundle exec whenever -w RAILS_ENV=production