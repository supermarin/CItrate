WORKING_DIR=$(pwd)
# CREATE USERS
create_user() {
  dscl . -create /Users/$1
  # dscl . -passwd /Users/$1 PASSWORD
  dscl . -create /Users/$1 UserShell /bin/bash
  dscl . -create /Users/$1 RealName "$1"
  dscl . -create /Users/$1 UniqueID $RANDOM
  dscl . -create /Users/$1 PrimaryGroupID 20 # 20 - staff
  mkdir -p /Users/$1
  chown -R $1:staff /Users/$1
  dscl . -create /Users/$1 NFSHomeDirectory /Users/$1
}
create_user git
create_user gitlab
echo "Created users!"

cd /Users/git

  # GENERATE SSH KEY
  sudo -u git -i mkdir -p .ssh
  sudo -u git ssh-keygen -q -N '' -t rsa -f .ssh/id_rsa

  # CLONE / INSTALL GITOLITE
  sudo -u git git clone -b gl-v304 https://github.com/gitlabhq/gitolite.git
  sudo -u git -H mkdir /Users/git/bin
  sudo -u git -H sh -c 'printf "%b\n%b\n" "PATH=\$PATH:/Users/git/bin" "export PATH" >> /Users/git/.profile'
  sudo -u git -H sh -c 'gitolite/install -ln /Users/git/bin'

  # COPY SSH PUBLIC KEY
  sudo -u git -H ln -s .ssh/id_rsa.pub GitlabAdmin.pub
  chmod 0444 GitlabAdmin.pub

  #INITIALIZE GITOLITE
  sudo -u git -i gitolite/src/gitolite setup -pk GitlabAdmin.pub

  # SET REPOSITORIES PERMISSIONS
  chmod -R g+rwX /Users/git/repositories/
  chown -R git /Users/git/repositories/
  echo "Installed gitolite."

cd $WORKING_DIR

cd /Users/gitlab

  #TEST - NOT NEEDED!

  sudo -u gitlab -i git clone git@localhost:gitolite-admin
  rm -rf gitolite-admin

  # CLONE GITLABHQ
  sudo -u gitlab -i git clone -b stable git://github.com/gitlabhq/gitlabhq.git

cd $WORKING_DIR