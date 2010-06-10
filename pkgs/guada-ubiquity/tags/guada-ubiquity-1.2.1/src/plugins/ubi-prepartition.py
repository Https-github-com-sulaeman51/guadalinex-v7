# -*- coding: utf-8; Mode: Python; indent-tabs-mode: nil; tab-width: 4 -*-
# «welcome» - Guadalinex welcome plugin
#
# Copyright (C) 2010 Junta de Andalucía
# Copyright (C) 2005, 2006, 2007, 2008, 2009, 2010 Canonical Ltd.
#
# Written by Adrian Belmonte <abelmonte@emergya.es>
# 
# Based in plugins written by: 
# Colin Watson <cjwatson@ubuntu.com>.
# Evan Dandrea <evand@ubuntu.com>
# Roman Shtylman <shtylman@gmail.com>
#
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

import sys
import os
import datetime
import subprocess
import math
import traceback
import syslog
import atexit
import signal
import xml.sax.saxutils
import gettext

import syslog

import pygtk
pygtk.require('2.0')
import pango
import gobject
import gtk.glade

import debconf

import time
import re
import PyICU

from ubiquity.plugin import *
from ubiquity import i18n
import ubiquity.tz

from ubiquity.components import install, partman_commit



from ubiquity.filteredcommand import FilteredCommand

from subprocess import Popen, PIPE

try:
    from ubiquity.DiskPreview.DiskPreview import DiskPreview
except:
    syslog.syslog("No pude cargar DiskPreview")

NAME = 'prepartition'
AFTER='language'
BEFORE= 'partman'
WEIGHT = 111

class GuadaPrePartition(FilteredCommand):
    def prepare(self):
        syslog.syslog("------->prepare guadaPrePartition")
        self.preseed('guada-ubiquity/prepartition', 'false')
        questions = ["^guada-ubiquity/prepartition"]
        env = {}
        self.frontend.diskpreview.mount_filesystems()
        return (['/usr/share/ubiquity/guada-prepartition'], questions, env)

    def run(self, priority, question):
        syslog.syslog("-------> run guadaPrePartition")
        if question.startswith('guada-ubiquity/prepartition'):
            #advanced = self.frontend.get_advanced()
            #self.preseed_bool('mythbuntu/advanced_install', advanced)
            print "question"

        return FilteredCommand.run(self, priority, question)

    def ok_handler(self):
        syslog.syslog("------->ok handler guadaPrePartition")
        return FilteredCommand.ok_handler(self)

    def cleanup(self):
        self.frontend.diskpreview.umount_filesystems()
        syslog.syslog("------>cleanup guadaPrePartition")
        return


class PageGtk(PluginUI):
    def __init__(self, controller, *args, **kwargs):
        self.controller = controller
        try:
            import gtk
            builder = gtk.Builder()
            self.controller.add_builder(builder)
            print >>sys.stderr, '--------------> PRE PARTITION Cargado'
#            builder.add_from_file('/usr/share/ubiquity/gtk/stepGuadaPrePartition.ui')
            builder.add_from_file('/usr/share/ubiquity/gtk/stepPrepartition.ui')
            builder.connect_signals(self)
            self.page = builder.get_object('stepGuadaPrePartition')
            print >>sys.stderr, '--------------> Despues de get object'
            self.disk_preview_area=builder.get_object('disk_preview_area1')
            self.diskpreview = DiskPreview()       
            dp = DiskPreview()
            dp.mount_filesystems()

#            self.disk_preview_area.add(self.diskpreview)
            self.disk_preview_area.add(dp)
            self.diskpreview=dp
            self.diskpreview.show_all()

        except Exception, e:
            self.debug('Could not create prepartition page: %s', e)
            self.page = None
        self.plugin_widgets = self.page

class Page (Plugin):
    def page (self):
        print >>sys.stderr,' ----->PREPARTITION PAGE!!!'

    def prepare (self, unfiltered=False):
        print >>sys.stderr,' ----->PREPARTITION PREPARE!!!'
#        self.frontend.diskpreview.mount_filesystems()

    def ok_handler(self):

        new_language = 'es'
        language_question= 'localechooser/languagelist '

        print >>sys.stderr,' ----->PREPARTITION OK HANDLER: NEW LANGUAGE %s' %new_language
        print >>sys.stderr,' ----->PREPARTITION OK HANDLER: SELF LANGUAGE QUESTION %s' %language_question

        Plugin.ok_handler(self)


