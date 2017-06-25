#!/bin/bash

# mmupdate.sh
#
# Simple script for comfortable update of Mattermost
# https://github.com/hobbyquaker/mattermost-update
#
# License: MIT
# Copyright (c) 2017 Sebastian Raff <hq@ccu.io>

VERSION="1.0.0"

MM_PATH=/opt/mattermost
MM_USER=mattermost
MM_GROUP=mattermost

command -v jq >/dev/null 2>&1 || { echo >&2 "This script requires jq but it's not installed.  Aborting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "This script requires wget but it's not installed.  Aborting."; exit 1; }
command -v sudo >/dev/null 2>&1 || { echo >&2 "This script requires sudo but it's not installed.  Aborting."; exit 1; }

SWD=`pwd`

TARBALL_FILE=`echo $1 | sed -r 's#.*\/(.*)$#\1#'`
NEW_BUILD_NUMBER=`echo ${TARBALL_FILE} | sed -r 's/^mattermost-([0-9.]+).*/\1/'`

cd ${MM_PATH}
MM_BUILD_NUMBER=`sudo -u ${MM_USER} ${MM_PATH}/bin/platform version | sed -nr 's/Build Number: ([0-9.]+)/\1/p'`

if [ "$NEW_BUILD_NUMBER" == "$MM_BUILD_NUMBER" ]
then
    echo >&2 "Build $MM_BUILD_NUMBER is already installed. Aborting."
    exit 1
fi

BACKUP_TMP_PATH=/tmp/mattermost.backup.${MM_BUILD_NUMBER}
NEW_TMP_PATH=/tmp/mattermost.update.${NEW_BUILD_NUMBER}
mkdir ${BACKUP_TMP_PATH} 2> /dev/null
${NEW_TMP_PATH} 2> /dev/null
mkdir ${NEW_TMP_PATH} 2> /dev/null

echo "   Downloading $1"
cd ${NEW_TMP_PATH}
wget -q $1 || { echo >&2 "Aborting."; exit 1; }
echo "   Extracting $TARBALL_FILE"
tar -xzf ${TARBALL_FILE} || { echo >&2 "Aborting."; exit 1; }
cd ${SWD}

echo "   Stopping Mattermost"
service mattermost stop || { echo >&2 "Aborting."; exit 1; }
BACKUP_FINAL_PATH=${MM_PATH}/backup/`date +%Y%m%d%H%M`_${MM_BUILD_NUMBER}

SQL_SETTINGS=`cat ${MM_PATH}/config/config.json | jq '.SqlSettings'`
DRIVER_NAME=`echo ${SQL_SETTINGS} | jq -r '.DriverName'`

if [ ${DRIVER_NAME} == "postgres" ]
then
    DATA_SOURCE=`echo ${SQL_SETTINGS} | jq -r '.DataSource'`
    DB_NAME=`echo ${DATA_SOURCE} | sed -r 's#.*\/\/([^?]+).*#\1#'`
    DB_DUMP_FILE=${BACKUP_TMP_PATH}/${DB_NAME}.pgdump.gz

    echo "   Dumping $DRIVER_NAME Database $DB_NAME to $DB_DUMP_FILE"
    cd ${MM_PATH}
    sudo -u ${MM_USER} pg_dump ${DB_NAME} | gzip > ${DB_DUMP_FILE} || { echo >&2 "Aborting."; exit 1; }

else
    # TODO - Implement MySql Backup
    echo "Error: Unknown Database Driver $DRIVER_NAME"
    exit 1
fi

echo "   Backing up config.json to $BACKUP_TMP_PATH/config.json"
cp ${MM_PATH}/config/config.json ${BACKUP_TMP_PATH}/ || { echo >&2 "Aborting."; exit 1; }

echo "   Backing up data folder to $BACKUP_TMP_PATH/data.tar.gz"
cd ${MM_PATH}
tar -czf ${BACKUP_TMP_PATH}/data.tar.gz data || { echo >&2 "Aborting."; exit 1; }
cd ${SWD}

echo "   Copying $NEW_BUILD_NUMBER to $MM_PATH"
cp -r ${NEW_TMP_PATH}/mattermost/* ${MM_PATH}/

echo "   Restoring config.json"
cp ${BACKUP_TMP_PATH}/config.json ${MM_PATH}/config/

echo "   Copying Backup to ${BACKUP_FINAL_PATH}"
mkdir -p ${BACKUP_FINAL_PATH} 2> /dev/null
cp -r ${BACKUP_TMP_PATH}/* ${BACKUP_FINAL_PATH}/

echo "   Changing Owner/Group of $MM_PATH to $MM_USER:$MM_GROUP"
chown -R ${MM_USER}:${MM_GROUP} ${MM_PATH}

echo "   Starting Mattermost"
service mattermost start

echo "   Cleaning up tmp folders"
rm -r ${NEW_TMP_PATH}
rm -r ${BACKUP_TMP_PATH}

echo "Done."
