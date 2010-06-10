#!/usr/bin/env python
# -*- coding: utf-8 -*-

### BEGIN LICENSE
# Copyright 2009 <Alfonso de Cala> <alfonso@el-magnifico.org>
#This program is free software: you can redistribute it and/or modify it 
#under the terms of the GNU General Public License version 3, as published 
#by the Free Software Foundation.
#
#This program is distributed in the hope that it will be useful, but 
#WITHOUT ANY WARRANTY; without even the implied warranties of 
#MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR 
#PURPOSE.  See the GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License along 
#with this program.  If not, see <http://www.gnu.org/licenses/>.
### END LICENSE

from distutils.core import setup
from DistUtilsExtra.command import *

setup(name='simplemag',
    version='0.0.1',
    license='GPL v3',
    author='Alfonso de Cala',
    author_email='alfonso@el-magnifico.org',
    url='https://launchpad.net/grubaker2',
    data_files=[('share/simplemag/data/',['data/magnify.png']),
                ('share/icons/',['data/simplemag.png']),
                ('share/applications/', ['data/simplemag.desktop']),
                ('bin/',['src/simplemag'])],
    cmdclass = { "build" : build_extra.build_extra,
        "build_i18n" :  build_i18n.build_i18n,
        "clean": clean_i18n.clean_i18n,
        }
    )


