#!/usr/bin/env python
# -*- encoding: utf-8 -*-

#David Amian y Alvaro Pinel
#amianlinux@gmail.com
#alvaro.pinel@gmail.com

import urllib
import nautilus
import gtk
import gtk.glade
import os
import time
import gettext
from threading import Thread
gtk.gdk.threads_init() 
gettext.install("nautilus-fontinstall")
# = gettext.translation('nautilus-fontinstall','/usr/share/locale/')
#t.install()


#Global
NAME_APP = "nautilus-fontinstall"
FORMAT = ["application/x-font-ttf"]
PATH = os.path.abspath(os.path.dirname(__file__))+"/"
PATH_ICON = "/usr/share/icons/"
FONT_PATH="/usr/share/fonts/truetype/"


class FONTDialog:	

    def main(self):
        thread = MiThread()
        thread.start()
        while thread.isAlive():
            time.sleep(0.09)
            self.pgbar.pulse()          
            while gtk.events_pending():
                gtk.main_iteration()
        self.pgbar.set_fraction(1.0)
        self.button.show()
        self.pgbar.set_text(_("Update completed"))
        self.lbFinish.set_text(_("The font '")+self.file_cut+_("' has been installed"))
       
	
	


    def __init__(self, filefont):
        self.filefont = filefont
        self.list_f = self.filefont.split('/')
        self.file_cut = self.filefont.split('/')[len(self.list_f)-1]
        self.glade = gtk.glade.XML(PATH+"fontinstall.glade")
        self.glade.signal_autoconnect(self)
        self.window = self.glade.get_widget("window1")
        self.button = self.glade.get_widget("buttonOk")
        self.lbFinish = self.glade.get_widget("lbFinish")
        self.pgbar = self.glade.get_widget("pgbar")
        self.lbFinish.set_text(_("Updating font cache"))
        
        self.window.set_title(NAME_APP)
        self.window.set_focus_child(self.glade.get_widget("buttonOk"))
        #self.window.set_icon_from_file(PATH_ICON+"fontinstall-ico.png")
        self.window.show_all()
        self.button.hide()
       
    def on_window1_delete_event(self, widget, event):
        widget.destroy()
	
    
    def on_buttonOk_clicked(self, widget):
        self.window.destroy()

class MiThread(Thread):
    def __init__(self):
        Thread.__init__(self)

    def run(self):
        os.system("fc-cache -vf")



#class MiThread(Thread):
#    def __init__(self):
#        Thread.__init__(self)

#    def run(self):
#        os.system("fc-cache -vf")

class FONTExtension(nautilus.MenuProvider):
    def __init__(self):
        pass
    
    def get_file_items(self, window, files):
        if len(files)!=1:
            return
        filename = files[0]

        if filename.get_mime_type() not in FORMAT:
            return
        items = []
        #Called when the user selects a file in Nautilus.
        item = nautilus.MenuItem("NautilusPython::fontinstall_item",
                                 _("Install Font"),
                                 _("Install Font"))
        item.set_property('icon', "fontinstall-ico")
        item.connect("activate", self.menu_activate_cb, files)
        items.append(item)
        return items
    
    def on_buttonOk_clicked(self, widget):
        self.window.destroy()
    
    def menu_activate_cb(self, menu, files):
        #Called when the user selects the menu.
        if len(files) != 1:
            return
        filename = files[0]
        if filename.get_uri_scheme() != 'file':
            return

        if filename.is_directory():
            return

        filefont = urllib.unquote(filename.get_uri()[7:])
        os.system ("gksudo -u root -k -m " + "\""+ _("Enter your user password") + "\"" + " /bin/echo " + "\"" + _("Do you have root access?") + "\"")
        os.system("sudo cp -r '" + filefont + "' '" + FONT_PATH + "'")
        fontinst = FONTDialog(filefont)
        fontinst.main()
        #thread = MiThread()
        #thread.start()
        #while thread.isAlive():
        #    time.sleep(0.09)
        #    while gtk.events_pending():
        #        gtk.main_iteration()
                
        #self.glade = gtk.glade.XML(PATH+"fontinstall.glade")
        #self.glade.signal_autoconnect(self)
        #self.window = self.glade.get_widget("window1")
        #self.button = self.glade.get_widget("buttonOk")
        #self.window.set_title(NAME_APP)
        #self.window.set_focus_child(self.glade.get_widget("buttonOk"))
        #self.lbFinish = self.glade.get_widget("lbFinish")
        #self.lbFinish.set_text(_("The font has been installed"))
        #self.window.show_all()

    


