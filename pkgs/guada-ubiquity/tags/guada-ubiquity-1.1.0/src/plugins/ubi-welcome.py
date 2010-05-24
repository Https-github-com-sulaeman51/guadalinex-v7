# -*- coding: utf-8; Mode: Python; indent-tabs-mode: nil; tab-width: 4 -*-





import os
import time
import re
import sys

import debconf
import PyICU

from ubiquity.plugin import *
from ubiquity import i18n
import ubiquity.tz

NAME = 'welcome'
#AFTER = 'language'
AFTER=None
BEFORE='timezone'
#BEFORE= 'language'
WEIGHT = 111

class PageGtk(PluginUI):
    def __init__(self, controller, *args, **kwargs):
        self.controller = controller
        print >>sys.stderr, 'LLEGA AQUI?!'
        try:
            import gtk
            builder = gtk.Builder()
            self.controller.add_builder(builder)
            print >>sys.stderr, '--------------> WELCOME Cargado'
            builder.add_from_file('/usr/share/ubiquity/gtk/stepGuadaWelcome.ui')
            builder.connect_signals(self)
            self.page = builder.get_object('stepGuadaWelcome')
            self.preseed()
#            self.setup_page()
        except Exception, e:
            self.debug('Could not create welcome page: %s', e)
            self.page = None
        self.plugin_widgets = self.page
    
    def preseed(self):
        print >>sys.stderr, 'LLEGA AQUI?!'
#        self.preseed('localechooser/language-name-fb','Spanish')
#        print >>sys.stderr, '------------->fb'
#        self.preseed('localechooser/language-name','Spanish')
#        print >>sys.stderr, '------------>name'
#        self.preseed('localechooser/language-name-ascii','Spanish')
#        print >>sys.stderr, '--------------->ascii'
        

class Page (Plugin):
    def page (self):
        print >>sys.stderr,' ----->PAGE!!!'

    def prepare (self, unfiltered=False):
        self.db.fset('localechooser/languagelist', 'seen', 'false')
#        localechooser_script = '/usr/lib/ubiquity/localechooser/localechooser'
        print >>sys.stderr,' ----->PREPARE!!!' 
#        self.preseed('localechooser/languagelist','es')
#        print >>sys.stderr,' ----->IT WORKED!!!'
    
    def ok_handler(self):
        
        new_language = 'es'
        language_question= 'localechooser/languagelist '
        self.preseed(language_question, new_language)
        print >>sys.stderr,' ----->OK HANDLER: NEW LANGUAGE %s' %new_language
        print >>sys.stderr,' ----->OK HANDLER: SELF LANGUAGE QUESTION %s' %language_question
        self.preseed('time/zone', 'Europe/Madrid')
        self.preseed('debian-installer/country', 'ES')
        self.preseed('console-setup/layout', 'España')
#        self.preseed('console-setup/variant', variant)

#        if (self.initial_language is None or
#            self.initial_language != new_language):
#            self.db.reset('debian-installer/country')
#        if self.ui.controller.oem_config:
#            self.preseed('oem-config/id', self.ui.get_oem_id())
        Plugin.ok_handler(self)
