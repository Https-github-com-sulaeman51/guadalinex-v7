#!/usr/bin/env python
# -*- encoding: utf-8 -*-

#David Amian y Alvaro Pinel
#david.amian@price-roch.es
#alvaro.pinel@price-roch.es

import gobject
import urllib
import nautilus
import ConfigParser
import mimetypes
import gtk
import pygtk
# We use the 2.0 gtk version
pygtk.require('2.0')
import gtk.glade
import os
import threading
import thread  
import time
import sys
import subprocess
import signal
from threading import Thread
gtk.gdk.threads_init() 

#Global
NAME_APP="nautilus-md5sum"
FORMAT=["application/x-cd-image"]
PATH=os.path.abspath(os.path.dirname(__file__))+"/"
PATH_ICON="/usr/share/icons/"



class MD5Dialog:	

	def main(self):
		self.thread = MiThread(self.lbMd5, self)
		self.thread.start()
		while self.thread.isAlive():
		     time.sleep(0.09)
		     self.pgbar.pulse()          
		     while gtk.events_pending():
		          gtk.main_iteration()
		self.pgbar.set_fraction(1.0)
		self.button.set_label("Ok")
		self.pgbar.set_text("Comprobación finalizada")
		self.lbDef.set_text("La suma MD5 del fichero '"+self.file_cut+"' es:")
		self.copy.show()
	
		


	def __init__(self, file):
		self.file=file
		self.list_f=self.file.split('/')
		self.file_cut= self.file.split('/')[len(self.list_f)-1]
		self.glade = gtk.glade.XML(PATH+"md5.glade")
        	self.glade.signal_autoconnect(self)
		self.window=self.glade.get_widget("window1")
		self.button=self.glade.get_widget("buttonOk")
		self.lbDef=self.glade.get_widget("lbDef")
		self.lbMd5=self.glade.get_widget("lbMd5")
		self.pgbar=self.glade.get_widget("pgbar")
		self.copy=self.glade.get_widget("copy")
		self.copy.set_label("Copiar")
		self.lbDef.set_text("La suma MD5 puede durar bastante tiempo")
		self.lbMd5.set_text("Fichero: "+self.file_cut)
		self.lbMd5.set_selectable(True)
		self.button.set_label("Cancelar")
		self.button.grab_default()
		self.button.grab_focus()
		self.window.set_title(NAME_APP)
		self.window.set_focus_child(self.glade.get_widget("buttonOk"))
		self.window.set_icon_from_file(PATH_ICON+"md5sum-ico.png")
		self.window.show_all()
		self.copy.hide()
		self.Res=subprocess.Popen(["md5sum",file], stdout=subprocess.PIPE)
		
	def on_window1_delete_event(self, widget, event):
		if self.Res.poll()==None:
			os.kill(self.Res.pid, signal.SIGKILL)
			time.sleep(0.1)
		widget.destroy()
	
	def on_copy_clicked(self, widget):
		clipboard=gtk.clipboard_get()
		clipboard.set_text(self.lbMd5.get_text())
		clipboard.store

	def on_buttonOk_clicked(self, widget):
		if widget.get_label()=="Cancelar":
			if self.Res.poll()==None:
				os.kill(self.Res.pid, signal.SIGKILL)
				time.sleep(0.1)
			self.window.destroy()
		else:
			if self.Res.poll()==None:
				os.kill(self.Res.pid, signal.SIGKILL)
				time.sleep(0.1)
			self.window.destroy()

class MiThread(Thread, gtk.Label, MD5Dialog):
        def __init__(self, label, md5):
                self.lb=label
                self.Res=md5.Res
                Thread.__init__(self)

        def run(self):
                res=self.Res.communicate()[0]
                result=res.split('/')[0]
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
        """Called when the user selects a file in Nautilus."""
        item = nautilus.MenuItem("NautilusPython::md5sum_item",
                                 "Calcular suma MD5",
                                 "Calcular suma MD5")
        item.connect("activate", self.menu_activate_cb, files)
        items.append(item)
        return items

    def menu_activate_cb(self, menu, files):
        """Called when the user selects the menu."""
        if len(files) != 1:
            return
        filename = files[0]
        if filename.get_uri_scheme() != 'file':
            return

        if filename.is_directory():
            return

        file = urllib.unquote(filename.get_uri()[7:])
	md5d=MD5Dialog(file)
	md5d.main()

