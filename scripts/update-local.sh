#!/usr/bin/env bash
set -e
source "`dirname $0`/common.sh"

# Backup database
INFO "Backing up database..."
DB_FILE="${LOCAL_DOMAIN}-${_NOW_}-before-update.sql"
TIME_START
wp db export ${DB_FILE} > ${_LOG_} 2>&1
TIME_STOP

# Synchronize uploads
INFO "Synchronizing uploads..."
TIME_START
rsync -ave "ssh -p 2222" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/wp-content/uploads/ wp-content/uploads/ --exclude node_modules --delete > ${_LOG_} 2>&1
TIME_STOP

# Synchronize database
INFO "Synchronizing database..."
DB_FILE="${DOMAIN}-${_NOW_}.sql"
TIME_START
ssh -p 2222 ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_PATH} && wp --allow-root --skip-plugins --skip-themes db export ${DB_FILE}" > ${_LOG_} 2>&1
ssh -p 2222 ${REMOTE_USER}@${REMOTE_HOST} "cat ${REMOTE_PATH}/${DB_FILE}" | wp db import - > ${_LOG_} 2>&1
ssh -p 2222 ${REMOTE_USER}@${REMOTE_HOST} "rm -f ${REMOTE_PATH}/${DB_FILE}" > ${_LOG_} 2>&1
TIME_STOP

# Replace domain
INFO "Replacing domain ${DOMAIN} => ${LOCAL_DOMAIN}..."
TIME_START
wp search-replace "https://${DOMAIN}" "http://${LOCAL_DOMAIN}" --all-tables > ${_LOG_} 2>&1
wp search-replace "${DOMAIN}" "${LOCAL_DOMAIN}" --all-tables > ${_LOG_} 2>&1
TIME_STOP

# Deactivate plugins
INFO "Deactivating plugins..."
TIME_START
wp plugin deactivate \
  ithemes-security-pro \
  wp-offload-ses \
> ${_LOG_} 2>&1
TIME_STOP

INFO "Local development site ready: http://${LOCAL_DOMAIN}"
