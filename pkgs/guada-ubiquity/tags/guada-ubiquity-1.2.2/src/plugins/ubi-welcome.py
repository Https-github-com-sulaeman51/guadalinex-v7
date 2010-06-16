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
import atexit
import signal


import debconf
import PyICU

from ubiquity.plugin import *
from ubiquity import i18n
import ubiquity.tz
from ubiquity import misc
from ubiquity import auto_update
from ubiquity import osextras


try:
    from ubiquity.DiskPreview.DiskPreview import DiskPreview
except:
    syslog.syslog("No pude cargar DiskPreview")


#NAME = 'welcome'

#We need to keep the original name due to some propeties in gtk_ui

NAME= 'language' 
AFTER=None
BEFORE='prepartition'
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
                self.kill_hermes()
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
                self.kill_hermes()           

            except Exception, e:
                self.debug('Could not create language page: %s', e)
                self.page = None

        self.plugin_widgets = self.page

    def kill_hermes(self):
# TODO: KILLHERMES: Probar sin solo falla la primera vez (no estaria del todo mal)
#        os.spawnlp(os.P_NOWAIT,'killall', 'killall', '-9', 'hermes_hardware.py')
        print >>sys.stderr, 'Hermes Killed'
#       atexit.register(self.launch_hermes)

#    def launch_hermes(self):
#        os.spawnlp(os.P_NOWAIT,'hermeshardware','hermeshardware') 
   
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
        print >>sys.stderr,' ----->Segundo OK HANDLER: NEW LANGUAGE %s' %new_language
        print >>sys.stderr,' ----->SegunOK HANDLER: SELF LANGUAGE QUESTION %s' %language_question
        args=[]
        model='pc105'
        layout='es'
        variant='es,es'
        options=['Spain']
        self.apply_real_keyboard(model, layout, variant, options)
        print >>sys.stderr,' ----->APPLY REAL KEYBOARD'
        self.rewrite_xorg_conf(model, layout, variant, options)  
        print >>sys.stderr,' ----->REWRITE XORG' 
        
    def ok_handler(self):
        #Preseed not needed, test if we can delete this.

        new_language = 'es'
        language_question= 'localechooser/languagelist '
        print >>sys.stderr,' ----->Segundo OK HANDLER: NEW LANGUAGE %s' %new_language
        print >>sys.stderr,' ----->SegunOK HANDLER: SELF LANGUAGE QUESTION %s' %language_question

        Plugin.ok_handler(self)

    def apply_real_keyboard(self, model, layout, variant, options):
        args = []
        if model is not None and model != '':
            args.extend(("-model", model))
        args.extend(("-layout", layout))
        if variant != '':
            args.extend(("-variant", variant))
        args.extend(("-option", ""))
        for option in options:
            args.extend(("-option", option))
        print >>sys.stderr,' ----->DENTRO APPLY REAL KEYBOARD'
        misc.execute("setxkbmap", *args)

    @misc.raise_privileges
    def rewrite_xorg_conf(self, model, layout, variant, options):
        print >>sys.stderr,' ----->DENTRO REWRITE XORG' 
        oldconfigfile = '/etc/X11/xorg.conf'
        newconfigfile = '/etc/X11/xorg.conf.new'
        try:
            oldconfig = open(oldconfigfile)
        except IOError:
            # Did they remove /etc/X11/xorg.conf or something? Oh well,
            # better to carry on than to crash.
            return
        newconfig = open(newconfigfile, 'w')

        re_section_inputdevice = re.compile(r'\s*Section\s+"InputDevice"\s*$')
        re_driver_kbd = re.compile(r'\s*Driver\s+"kbd"\s*$')
        re_endsection = re.compile(r'\s*EndSection\s*$')
        re_option_xkbmodel = re.compile(r'(\s*Option\s*"XkbModel"\s*).*')
        re_option_xkblayout = re.compile(r'(\s*Option\s*"XkbLayout"\s*).*')
        re_option_xkbvariant = re.compile(r'(\s*Option\s*"XkbVariant"\s*).*')
        re_option_xkboptions = re.compile(r'(\s*Option\s*"XkbOptions"\s*).*')
        in_inputdevice = False
        in_inputdevice_kbd = False
        done = {'model': model == '', 'layout': False,
                'variant': variant == '', 'options': options == ''}

        for line in oldconfig:
            line = line.rstrip('\n')
            if re_section_inputdevice.match(line) is not None:
                in_inputdevice = True
            elif in_inputdevice and re_driver_kbd.match(line) is not None:
                in_inputdevice_kbd = True
            elif re_endsection.match(line) is not None:
                if in_inputdevice_kbd:
                    if not done['model']:
                        print >>newconfig, ('\tOption\t\t"XkbModel"\t"%s"' %
                                            model)
                    if not done['layout']:
                        print >>newconfig, ('\tOption\t\t"XkbLayout"\t"%s"' %
                                            layout)
                    if not done['variant']:
                        print >>newconfig, ('\tOption\t\t"XkbVariant"\t"%s"' %
                                            variant)
                    if not done['options']:
                        print >>newconfig, ('\tOption\t\t"XkbOptions"\t"%s"' %
                                            options)
                in_inputdevice = False
                in_inputdevice_kbd = False
                done = {'model': model == '', 'layout': False,
                        'variant': variant == '', 'options': options == ''}
            elif in_inputdevice_kbd:
                match = re_option_xkbmodel.match(line)
                if match is not None:
                    if model == '':
                        # hmm, not quite sure what to do here; guessing that
                        # forcing to pc105 will be reasonable
                        line = match.group(1) + '"pc105"'
                    else:
                        line = match.group(1) + '"%s"' % model
                    done['model'] = True
                else:
                    match = re_option_xkblayout.match(line)
                    if match is not None:
                        line = match.group(1) + '"%s"' % layout
                        done['layout'] = True
                    else:
                        match = re_option_xkbvariant.match(line)
                        if match is not None:
                            if variant == '':
                                continue # delete this line
                            else:
                                line = match.group(1) + '"%s"' % variant
                            done['variant'] = True
                        else:
                            match = re_option_xkboptions.match(line)
                            if match is not None:
                                if options == '':
                                    continue # delete this line
                                else:
                                    line = match.group(1) + '"%s"' % options
                                done['options'] = True
            print >>newconfig, line

        newconfig.close()
        oldconfig.close()
        os.rename(newconfigfile, oldconfigfile)
 


class Install(InstallPlugin):
    def prepare(self, unfiltered=False):
        if 'UBIQUITY_OEM_USER_CONFIG' in os.environ:
            return (['/usr/lib/ubiquity/localechooser-apply'], [])
        else:
            print >>sys.stderr,' ----->APLICANDO INSTALL'
            return (['sh', '-c',
                     '/usr/lib/ubiquity/localechooser/post-base-installer ' +
                     '&& /usr/lib/ubiquity/localechooser/finish-install' + '&& /usr/share/ubiquity/console-setup-apply'], [])

    def install(self, target, progress, *args, **kwargs):
        progress.info('ubiquity/install/locales')
        rv = InstallPlugin.install(self, target, progress, *args, **kwargs)
        if not rv:
            # fontconfig configuration needs to be adjusted based on the
            # selected locale (from language-selector-common.postinst). Ignore
            # errors.
            misc.execute('chroot', target, 'fontconfig-voodoo', '--auto', '--force', '--quiet')
        return rv

