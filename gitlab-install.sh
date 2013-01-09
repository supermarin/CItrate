# /bin/bash
#
# Gitolite / GitlabHQ / GitlabCI installation script. OSX 10.8 and up.
# Author: Marin Usalj [mneorr@gmail.com]

WORKING_DIR=$(pwd)

create_group() {
  dscl . create /Groups/git
  dscl . create /Groups/git gid 789
}
create_user() {
  dscl . -create /Users/$1
  # dscl . -passwd /Users/$1 PASSWORD
  dscl . -create /Users/$1 UserShell /bin/bash
  dscl . -create /Users/$1 RealName "$1"
  dscl . -create /Users/$1 UniqueID $RANDOM
  dscl . -create /Users/$1 PrimaryGroupID 789
  mkdir -p /Users/$1
  chown -R $1:git /Users/$1
  dscl . -create /Users/$1 NFSHomeDirectory /Users/$1
}

create_user git
create_user gitlab
echo "Created users!"

# GENERATE GITLAB SSH KEYS
sudo -u gitlab -i mkdir -p /Users/gitlab/.ssh
sudo -u gitlab ssh-keygen -q -N '' -t rsa -f /Users/gitlab/.ssh/id_rsa

cd /Users/git

  # CLONE / INSTALL GITOLITE
  sudo -u git git clone -b gl-v304 https://github.com/gitlabhq/gitolite.git
  sudo -u git -H mkdir /Users/git/bin
  sudo -u git -H sh -c 'printf "%b\n%b\n" "PATH=\$PATH:/Users/git/bin" "export PATH" >> /Users/git/.profile'
  sudo -u git -H sh -c 'gitolite/install -ln /Users/git/bin'

  # COPY GITLAB'S SSH PUBLIC KEY
  sudo -u git -H ln -s /Users/gitlab/.ssh/id_rsa.pub GitlabAdmin.pub
  chmod 0444 GitlabAdmin.pub

  #INITIALIZE GITOLITE
  sudo -u git -i gitolite/src/gitolite setup -pk GitlabAdmin.pub

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
    sudo -u gitlab -H git checkout 4-0-stable
    
    # MAKE SURE GITLAB CAN WRITE TO THE LOG/ AND TMP/ DIRECTORIES
    sudo chown -R gitlab log/
    sudo chown -R gitlab tmp/
    sudo chmod -R u+rwX  log/
    sudo chmod -R u+rwX  tmp/

    # COPY STANDARD CONFIGURATION FILES
    sudo -u gitlab -H cp config/gitlab.yml.example config/gitlab.yml
    sudo -u gitlab cp config/database.yml.postgresql config/database.yml

    # SETUP GITLAB HOOKS
    sudo cp ./lib/hooks/post-receive /Users/git/.gitolite/hooks/common/post-receive
    sudo chown git:git /Users/git/.gitolite/hooks/common/post-receive

    # INSTALL GEMS
    sudo -u gitlab -H bundle install --deployment --without development test mysql
    echo "Installed Gitlab."

    # CONFIGURE DATABASE (PostgreSQL)
    createuser -S gitlab
    createdb -Ogitlab gitlabhq_production
    sudo perl -pi -e 's/postgres$/gitlab/g' config/database.yml
    sudo perl -pi -e 's/# host: localhost/host: localhost/' config/database.yml
    
    # INITIALIZE DATABASE AND ACTIVATE ADVANCED FEATURES
    sudo -u gitlab -H bundle exec rake gitlab:app:setup RAILS_ENV=production

cd $WORKING_DIR