#!/bin/bash
# 
#
# Copyright (C) 2010, Junta de Andalucia
# Author(s): Roberto C. Morano <rcmorano@emergya.es>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.  See http://www.gnu.org/copyleft/gpl.html for
# the full text of the license.

uscan && uupdate $(ls -rthal ../*tag.gz|grep -v orig|awk \'{for (i=1;i<=NF;i++)  if ( $i ~ "gz" ) print $i}')
