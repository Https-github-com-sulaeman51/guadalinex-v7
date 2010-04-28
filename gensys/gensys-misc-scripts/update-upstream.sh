#!/bin/bash -x
# 
# Updates upstream release for a debian package
#
# Copyright (C) 2010, Junta de Andalucia
# Author(s): Roberto C. Morano <rcmorano@emergya.es>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.  See http://www.gnu.org/copyleft/gpl.html for
# the full text of the license.


uscan --verbose
TGZ=$(ls -rthal ../*tar.gz|grep -v orig|awk '{for (i=1;i<=NF;i++)  if ( $i ~ "gz" ) print $i}')
test -f $TGZ || exit 0
TGZ_ORIG=$(echo $TGZ | sed 's/-\([0-9].*\)tar.gz/_\1orig.tar.gz/g')

# cleaning
test -h "$TGZ_ORIG" && rm -f "$TGZ_ORIG"
test -d ${TGZ%.tar.gz} && rm -rf ${TGZ%.tar.gz}
test -d ${TGZ_ORIG%.tar.gz} && rm -rf ${TGZ_ORIG%.tar.gz}


cp $TGZ $TGZ_ORIG
tar zvxf $TGZ_ORIG -C ../
cp -a ${TGZ%.tar.gz} ${TGZ_ORIG%.tar.gz}
exit 0
