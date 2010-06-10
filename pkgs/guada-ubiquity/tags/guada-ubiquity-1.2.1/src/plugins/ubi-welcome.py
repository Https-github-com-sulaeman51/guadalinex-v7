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

import os
import time
import re
import sys

import debconf
import PyICU

from ubiquity.plugin import *
from ubiquity import i18n
import ubiquity.tz
from ubiquity import misc
from ubiquity import auto_update
from ubiquity import osextras



#NAME = 'welcome'

#We need to keep the original name due to some propeties in gtk_ui

NAME= 'language' 
AFTER=None
BEFORE='timezone'
WEIGHT = 111

class PageGtk(PluginUI):
    def __init__(self, controller, *args, **kwargs):
        self.controller = controller
        if not 'UBIQUITY_GREETER' in os.environ:
            # Not Greeter, so we show guadawelcome window
            ui_file = 'stepGuadaWelcome.ui'
            try:
                import gtk
                builder = gtk.Builder()
                self.controller.add_builder(builder)
                builder.add_from_file('/usr/share/ubiquity/gtk/%s' % ui_file)
                builder.connect_signals(self)
                self.page = builder.get_object('stepGuadaWelcome')
                self.welcome_image=builder.get_object('welcome_image')
                self.welcome_image.set_from_file("/usr/share/guada-ubiquity/pics/photo_1024.jpg")
                self.preseed()
                
            except Exception, e:
                self.debug('Could not create welcome page: %s', e)
                self.page = None
 
        else:
            ui_file='stepGreeter.ui'
            try:            
                import gtk
                builder = gtk.Builder()
                self.controller.add_builder(builder)
                builder.add_from_file('/usr/share/ubiquity/gtk/%s' % ui_file)
                builder.connect_signals(self) 
                self.page = builder.get_object('stepGreeter')
                self.instalar_ubuntu = builder.get_object('instalar_ubuntu')
                self.probar_ubuntu = builder.get_object('probar_ubuntu')
                self.probar_text=builder.get_object('probar_text_label')
                self.listo_text=builder.get_object('listo_text_label')
                self.recomendation_text=builder.get_object('recomendation_label')

                def inst(*args):
                    self.probar_ubuntu.set_sensitive(False)
                    self.controller.go_forward()
                self.instalar_ubuntu.connect('clicked', inst)
                self.probar_ubuntu.connect('clicked',self.on_try_ubuntu_clicked)
                self.live_installer=builder.get_object('live_installer')

            except Exception, e:
                self.debug('Could not create language page: %s', e)
                self.page = None
        self.plugin_widgets = self.page
    
    def preseed(self):
        print >>sys.stderr, 'Preseed not used'

    @only_this_page
    def on_try_ubuntu_clicked(self, *args):
        # Spinning cursor.
        self.controller.allow_change_step(False)
        # Queue quit.
        self.instalar_ubuntu.set_sensitive(False)
        self.controller._wizard.current_page = None
        self.controller.dbfilter.ok_handler()


class Page (Plugin):
    def page (self):
        print >>sys.stderr,'Debug: page created'

    def prepare (self, unfiltered=False):
        self.db.fset('localechooser/languagelist', 'seen', 'false')
        print >>sys.stderr,'Debug: prepare' 

    
    def ok_handler(self):
        #Preseed not needed, test if we can delete this.

        new_language = 'es'
        language_question= 'localechooser/languagelist '
#        self.preseed(language_question, new_language)
        print >>sys.stderr,' ----->OK HANDLER: NEW LANGUAGE %s' %new_language
        print >>sys.stderr,' ----->OK HANDLER: SELF LANGUAGE QUESTION %s' %language_question
#        self.preseed('time/zone', 'Europe/Madrid')
#        self.preseed('debian-installer/country', 'ES')
#        self.preseed('console-setup/layout', 'España')

        Plugin.ok_handler(self)



class Install(InstallPlugin):
    def prepare(self, unfiltered=False):
        if 'UBIQUITY_OEM_USER_CONFIG' in os.environ:
            return (['/usr/lib/ubiquity/localechooser-apply'], [])
        else:
            return (['sh', '-c',
                     '/usr/lib/ubiquity/localechooser/post-base-installer ' +
                     '&& /usr/lib/ubiquity/localechooser/finish-install'], [])

    def install(self, target, progress, *args, **kwargs):
        progress.info('ubiquity/install/locales')
        rv = InstallPlugin.install(self, target, progress, *args, **kwargs)
        if not rv:
            # fontconfig configuration needs to be adjusted based on the
            # selected locale (from language-selector-common.postinst). Ignore
            # errors.
            misc.execute('chroot', target, 'fontconfig-voodoo', '--auto', '--force', '--quiet')
        return rv

