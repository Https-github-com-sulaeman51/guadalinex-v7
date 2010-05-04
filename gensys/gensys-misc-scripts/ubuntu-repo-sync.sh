#!/bin/bash -x

# Script que sincroniza el repo Ubuntu.

SERVER="mollina"
DEST="/var/gensys/deb-repositories/ubuntu"
DATE=`/bin/date +%d-%m-%Y_%H:%M:%S`
DIST="lucid,lucid-security,lucid-updates,lucid-backports"
OPTS="--nocleanup --passive --method=http --progress --host=v7.guadalinex.org --root=ubuntu --dist=$DIST --section=main,multiverse,universe,restricted  --arch=i386 --ignore-small-errors --ignore-release-gpg --ignore-missing-release --timeout=999"
ERR_MSG="No se ha ejecutado la sincronización correctamente. Por favor, revisa el fichero de log $LOG_FILE' para obtener mas detalle."
SUBJ="Error `basename $0` en $SERVER"
LOG_DIR=/var/gensys/deb-repositories/ubuntu
LOG_FILE=ubuntu-reposync-lucid.log

TEE_BIN=/usr/bin/tee
DEBMIRROR_BIN=/usr/bin/debmirror
MAIL_BIN=/usr/bin/mail

# Escribo fecha en el log
echo -e "\n\n\n"
echo $DATE 1>>$LOG_DIR/$LOG_FILE
echo "------------------------- main,restricted,universe,multiverse sections download (deb and sources) ---------------------"
# Sincronizo
$DEBMIRROR_BIN $OPTS $DEST 2>>$LOG_DIR/$LOG_FILE | $TEE_BIN -a $LOG_DIR/$LOG_FILE
DEBMIRROR_EXIT=$?


if [ $? -ne 0 ];then
        echo $ERR_MSG | $MAIL_BIN -s $SUBJ $ADMINS
        exit 1
fi

# Download Translation-es and Contents.gz
wget http://v7.guadalinex.org/ubuntu/dists/lucid/Contents-i386.gz -O $DEST/dists/lucid/Contents-i386.gz 2>> $LOG_DIR/$LOG_FILE
wget http://v7.guadalinex.org/ubuntu/dists/lucid/main/i18n/Translation-es -O $DEST/dists/lucid/main/i18n/Translation-es 2>> $LOG_DIR/$LOG_FILE
wget http://v7.guadalinex.org/ubuntu/dists/lucid/main/i18n/Translation-es.bz2 -O $DEST/dists/lucid/main/i18n/Translation-es.bz2 2>> $LOG_DIR/$LOG_FILE
wget http://v7.guadalinex.org/ubuntu/dists/lucid/main/i18n/Translation-es.gz -O $DEST/dists/lucid/main/i18n/Translation-es.gz 2>> $LOG_DIR/$LOG_FILE

exit 0

