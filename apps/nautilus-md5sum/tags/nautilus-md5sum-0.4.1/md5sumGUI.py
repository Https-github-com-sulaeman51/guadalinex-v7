#!/usr/bin/env python
# -*- encoding: utf-8 -*-

#David Amian y Alvaro Pinel
#amialinux@gmail.com
#alvaropinel@gmail.com

import gtk
import pygtk
# We use the 2.0 gtk version
pygtk.require('2.0')
import gtk.glade
import gobject
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
FILE="/home/test/guadalinex-v6-desktop-cd.iso"
LIST_F=FILE.split('/')
FILE_CUT= FILE.split('/')[len(LIST_F)-1]
Res=subprocess.Popen(["md5sum",FILE], stdout=subprocess.PIPE)

class MiThread(Thread, gtk.Label):  
	def __init__(self, label):
		self.lb=label  
		Thread.__init__(self)  
 
	def run(self): 
 		#print "ENTRA!"
		res=Res.communicate()[0]
		result=res.split('/')[0]
		self.lb.set_text(result)
	#	print "Termina"


class MD5Dialog:	

	def main(self):
		self.thread = MiThread(self.lbMd5)
		self.thread.start()
		while self.thread.isAlive():
		     time.sleep(0.09)
		     self.pgbar.pulse()          
		     while gtk.events_pending():
		          gtk.main_iteration()
		self.pgbar.set_fraction(1.0)
		self.button.set_label("Ok")
		self.pgbar.set_text("Comprobación finalizada")
		self.lbDef.set_text("La suma MD5 del fichero '"+FILE_CUT+"' es:")
                gtk.main()
		


	def __init__(self):
		self.glade = gtk.glade.XML("md5.glade")
        	self.glade.signal_autoconnect(self)
		self.window=self.glade.get_widget("window1")
		self.button=self.glade.get_widget("buttonOk")
		self.lbDef=self.glade.get_widget("lbDef")
		self.lbMd5=self.glade.get_widget("lbMd5")
		self.pgbar=self.glade.get_widget("pgbar")
		self.lbDef.set_text("La suma MD5 puede durar bastante tiempo")
		self.lbMd5.set_text("Fichero: "+FILE_CUT)
		self.button.set_label("Cancelar")
		self.button.grab_default()
		self.button.grab_focus()
		self.window.set_title(NAME_APP)
		self.window.set_focus_child(self.glade.get_widget("buttonOk"))
		self.window.show_all()
		
	def on_window1_delete_event(self, widget, event):
		if Res.poll()==None:
			os.kill(Res.pid, signal.SIGTERM)
			time.sleep(0.1)
		sys.exit()

	def on_buttonOk_clicked(self, widget):
		if widget.get_label()=="Cancelar":
			if Res.poll()==None:
				os.kill(Res.pid, signal.SIGKILL)
				time.sleep(0.1)
			sys.exit()
		else:
			if Res.poll()==None:
				os.kill(Res.pid, signal.SIGKILL)
				time.sleep(0.1)
			sys.exit()

if __name__ == "__main__":
	md5d = MD5Dialog()
#	print "A main"
	md5d.main()

