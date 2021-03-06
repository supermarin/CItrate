# /bin/bash
#
# Gitolite / GitlabHQ / GitlabCI installation script. OSX 10.8 and up.
# Author: Marin Usalj [mneorr@gmail.com]

source functions.sh

create_group
create_user git "Git"
create_user gitlab "GitlabHQ"
echo "Created users!"

# GENERATE GITLAB SSH KEYS
sudo -u gitlab -i mkdir -p /Users/gitlab/.ssh
sudo -u gitlab ssh-keygen -q -N '' -t rsa -f /Users/gitlab/.ssh/id_rsa

cd /Users/git

  # CLONE / INSTALL GITOLITE
  sudo -u git -H git clone -b gl-v320 https://github.com/gitlabhq/gitolite.git /Users/git/gitolite
  sudo -u git -H mkdir /Users/git/bin
  sudo -u git -H sh -c 'printf "%b\n%b\n" "PATH=\$PATH:/Users/git/bin" "export PATH" >> /Users/git/.profile'
  sudo -u git -H sh -c 'gitolite/install -ln /Users/git/bin'

  # COPY GITLAB'S SSH PUBLIC KEY
  sudo cp /Users/gitlab/.ssh/id_rsa.pub /Users/git/gitlab.pub
  sudo chmod 0444 /Users/git/gitlab.pub

  #INITIALIZE GITOLITE
  sudo -u git -H sh -c "PATH=/Users/git/bin:$PATH; gitolite setup -pk /Users/git/gitlab.pub"

  # SET CONFIG PERMISSIONS
  sudo chmod 750 /Users/git/.gitolite/
  sudo chown -R git:git /Users/git/.gitolite/

  # SET REPOSITORIES PERMISSIONS
  sudo chmod -R ug+rwXs,o-rwx /Users/git/repositories/
  sudo chown -R git:git /Users/git/repositories/
  echo "Installed gitolite."


# CLONE / INSTALL GITLAB
cd /Users/gitlab

  #TEST
  sudo -u gitlab -i git clone git@localhost:gitolite-admin
  rm -rf gitolite-admin

  # CLONE GITLABHQ
  sudo -u gitlab -H git clone https://github.com/gitlabhq/gitlabhq.git gitlab
  
  cd gitlab
    sudo -u gitlab -H git checkout 4-1-stable
    
    # MAKE SURE GITLAB CAN WRITE TO THE LOG/ AND TMP/ DIRECTORIES
    sudo chown -R gitlab log/
    sudo chown -R gitlab tmp/
    sudo chmod -R u+rwX  log/
    sudo chmod -R u+rwX  tmp/

    # COPY STANDARD CONFIGURATION FILES
    sudo -u gitlab -H cp config/gitlab.yml.example config/gitlab.yml
    sudo -u gitlab cp config/database.yml.postgresql config/database.yml

    # SETUP GITLAB HOOKS
    sudo -u git cp /Users/gitlab/gitlab/lib/hooks/post-receive /Users/git/.gitolite/hooks/common/post-receive
    sudo chown git:git /Users/git/.gitolite/hooks/common/post-receive

    # INSTALL GEMS
    sudo -u gitlab -H bundle install --deployment --without development test mysql
    echo "Installed Gitlab."
    
    echo "Creating gitlab postgres user"
    createuser -d gitlab
    sudo -u gitlab -H createdb -Ogitlab gitlabhq_production
    
    sudo perl -pi -e 's/postgres$/gitlab/g' config/database.yml
    sudo perl -pi -e 's/# host: localhost/host: localhost/' config/database.yml
    
    # CONFIGURE GIT
    sudo -u gitlab -H git config --global user.name "GitLab"
    sudo -u gitlab -H git config --global user.email "gitlab@localhost"

    # INITIALIZE DATABASE AND ACTIVATE ADVANCED FEATURES
    sudo -u gitlab -H bundle exec rake gitlab:setup RAILS_ENV=production
    # TEST PRODUCTION:
    sudo -u gitlab -H bundle exec rake gitlab:check RAILS_ENV=production