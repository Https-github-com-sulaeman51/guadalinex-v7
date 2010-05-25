#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
# Copyright (c) 2009, Junta de Andalucía <packmaster@guadalinex.org>
#
# This package is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This package is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this package; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#
# Authors : David Amian <david.amian@price-roch.es>
#           Alvaro Pinel <alvaro.pinel@price-roch.es>

import urllib
import nautilus
import gtk
import pygtk
# We use the 2.0 gtk version
pygtk.require('2.0')
import gtk.glade
import os
import time
import subprocess
import signal
import gettext
from threading import Thread
gtk.gdk.threads_init() 
gettext.install("nautilus-md5sum")

#Global
NAME_APP = "nautilus-md5sum"
FORMAT = ["application/x-cd-image"]
PATH = "/usr/share/nautilus-md5sum/"
PATH_ICON = "/usr/share/icons/"



class MD5Dialog:	

    def main(self):
        thread = MiThread(self.lbMd5, self)
        thread.start()
        while thread.isAlive():
            time.sleep(0.09)
            self.pgbar.pulse()          
            while gtk.events_pending():
                gtk.main_iteration()
        self.pgbar.set_fraction(1.0)
        self.button.set_label(_("Ok"))
        self.pgbar.set_text(_("Checking completed"))
        self.lbDef.set_text(_("MD5Sum of '")+self.file_cut+_("' is:"))
        self.copy.show()
	
	


    def __init__(self, fileiso):
        self.fileiso = fileiso
        self.list_f = self.fileiso.split('/')
        self.file_cut = self.fileiso.split('/')[len(self.list_f)-1]
        self.glade = gtk.glade.XML(PATH+"md5.glade")
        self.glade.signal_autoconnect(self)
        self.window = self.glade.get_widget("window1")
        self.button = self.glade.get_widget("buttonOk")
        self.lbDef = self.glade.get_widget("lbDef")
        self.lbMd5 = self.glade.get_widget("lbMd5")
        self.pgbar = self.glade.get_widget("pgbar")
        self.copy = self.glade.get_widget("copy")
        self.copy.set_label(_("Copy"))
        self.lbDef.set_text(_("MD5Sum can take a long time"))
        self.lbMd5.set_text(_("File: ")+self.file_cut)
        self.lbMd5.set_selectable(True)
        self.button.set_label(_("Cancel"))
        self.button.grab_default()
        self.button.grab_focus()
        self.window.set_title(NAME_APP)
        self.window.set_focus_child(self.glade.get_widget("buttonOk"))
        self.window.set_icon_from_file(PATH_ICON+"md5sum-ico.png")
        self.window.show_all()
        self.copy.hide()
        self.Res = subprocess.Popen(["md5sum", fileiso], stdout=subprocess.PIPE)
	
    def on_window1_delete_event(self, widget, event):
        if self.Res.poll()==None:
            os.kill(self.Res.pid, signal.SIGKILL)
            time.sleep(0.1)
        widget.destroy()
	
    def on_copy_clicked(self, widget):
        clipboard = gtk.clipboard_get()
        clipboard.set_text(self.lbMd5.get_text())
        clipboard.store

    def on_buttonOk_clicked(self, widget):
        if self.Res.poll()==None:
            os.kill(self.Res.pid, signal.SIGKILL)
            time.sleep(0.1)
        self.window.destroy()

class MiThread(Thread):
    def __init__(self, label, md5):
        self.lb = label
        self.Res = md5.Res
        Thread.__init__(self)

    def run(self):
        res = self.Res.communicate()[0]
        result = res.split('/')[0]
        self.lb.set_text(str(result.rstrip()))



class MD5Extension(nautilus.MenuProvider):
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
        item = nautilus.MenuItem("NautilusPython::md5sum_item",
                                 _("Check MD5Sum"),
                                 _("Check MD5Sum"))
        item.set_property('icon', "md5sum-ico")
        item.connect("activate", self.menu_activate_cb, files)
        items.append(item)
        return items

    def menu_activate_cb(self, menu, files):
        #Called when the user selects the menu.
        if len(files) != 1:
            return
        filename = files[0]
        if filename.get_uri_scheme() != 'file':
            return

        if filename.is_directory():
            return

        fileiso = urllib.unquote(filename.get_uri()[7:])
        md5d = MD5Dialog(fileiso)
        md5d.main()

