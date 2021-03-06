#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

source=$1
tmp_dir="/tmp/source"

get-archive.sh "${source}" "${tmp_dir}" "zip"

# Import db.
if [[ -f "${tmp_dir}/database.sql" ]]; then
    echo "DB dump found. Importing..."

    mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "DROP DATABASE IF EXISTS ${DB_NAME};"
    mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" -e "CREATE DATABASE ${DB_NAME};"
    mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" < "${tmp_dir}/database.sql"
else
    echo "No db dump found for import"
fi

# Import files.
if [[ -d "${tmp_dir}/wp-content/uploads" ]]; then
    echo "Files directory found: wp-content/uploads. Importing..."

    rsync -rlt --force "${tmp_dir}/wp-content/uploads/" "${FILES_DIR}/public/"
    rm -rf "${tmp_dir}/wp-content/uploads"
else
    echo "No files directory (wp-content/uploads) found for import"
fi

rm -rf "${tmp_dir}"
