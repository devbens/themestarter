#!/usr/bin/env bash
set -e
GITPROFILE=benjophp
PROJECT=${PWD##*/}
DB_NAME="wp_${PROJECT/-/_}"
GIT_URL="https://gitlab.com/${GITPROFILE}/${PROJECT}.git"
GIT_ORIGIN="ssh://git@gitlab.com:benjophp/${GITPROFILE}/${PROJECT}.git"

# Rename project
sed -i -e "s/wp-boilerplate/${PROJECT}/g" .cpanel.yml .gitignore composer.json

# Create database
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"

# Download / configure / install WordPress
wp core download --force --skip-content
wp core config --dbname=${DB_NAME}

# Create plugins / themes / uploads directories
mkdir -p wp-content/plugins wp-content/themes wp-content/uploads

# Initialize git repository
git init
git remote add origin ${GIT_ORIGIN} > /dev/null 2>&1
git fetch > /dev/null 2>&1 || error_code=$?
if [ "${error_code-0}" -eq 0 ]; then
  git checkout master -f > /dev/null 2>&1
else
  git remote remove origin > /dev/null 2>&1
  git add -A > /dev/null 2>&1
  git commit -am 'Initial WordPress project' > /dev/null 2>&1
fi

# Done
echo "Site ready at http://${PROJECT}.${TLD-localhost.test}"
