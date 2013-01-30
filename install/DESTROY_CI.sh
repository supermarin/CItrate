echo "Deleting users..."
sudo dscl . delete /Users/gitlab_ci
sudo rm -rf /Users/gitlab_ci /Users/gitlab_ci
echo "Deleting databases..."
dropdb gitlab_ci_production
dropuser gitlab_ci
