#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
#       createmosaic.py
#       
#       Copyright 2009 D. Amian <amialinux@gmail.com>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

import gtk
import pygtk
pygtk.require('2.0')
import gtk.glade
import sendfile
import os
import subprocess
import process
import time
import mosaic
from threading import Thread

class CreateMosaic():
    def __init__(self, vbmosaic):
        self.mosaic=vbmosaic
        self.glade = gtk.glade.XML(mosaic.PATH+"glade/createmosaic.glade")
        self.glade.signal_autoconnect(self)
        self.wdcreatemosaic = self.glade.get_widget("wdcreatemosaic")
        self.txtpathorig = self.glade.get_widget("txtpathorig")
        self.txtpathmosaic = self.glade.get_widget("txtpathmosaic")
        self.spbtscale = self.glade.get_widget("spbtscale")
        self.spbtdistance = self.glade.get_widget("spbtdistance")
        self.spbtcheat = self.glade.get_widget("spbtcheat")
        self.wdcreatemosaic.connect("destroy", self.destroy)
        
        self.txtpathorig.set_text(self.mosaic.orig)
        self.spbtscale.set_value(self.mosaic.scale)
        self.spbtdistance.set_value(self.mosaic.distance)
        self.spbtcheat.set_value(self.mosaic.cheat)
        
        self.wdcreatemosaic.show_all()
        self.wdcreatemosaic.set_icon_from_file(mosaic.PATH_ICON+"getapixel_46x46.png")
        

    def on_btSelect1_clicked(self, widget, data=None):
        chooser=sendfile.SendFile(self.mosaic,None,self,"orig",gtk.FILE_CHOOSER_ACTION_OPEN, "Seleccione la foto original")
        
        
    
    def on_btSelect2_clicked(self, widget, data=None):
        chooser=sendfile.SendFile(self.mosaic,None,self,"mosaic",gtk.FILE_CHOOSER_ACTION_SAVE, "Guardar mosaico como...")
        
    def on_btcancel_clicked(self, widget, data=None):
        self.wdcreatemosaic.destroy()
        
    def on_btok_clicked(self, widget, data=None):
        self.scale= self.spbtscale.get_value_as_int()    
        self.distance= self.spbtdistance.get_value_as_int()    
        self.cheat= self.spbtcheat.get_value_as_int()  
        self.orig=self.txtpathorig.get_text()
        self.output=self.txtpathmosaic.get_text()
        
        
        if self.txtpathorig.get_text_length() <= 0 or  self.txtpathmosaic.get_text_length() <= 0:
            mosaic.on_dialog(self.wdcreatemosaic, "Por favor debe seleccionar una imagen origen y una destino", gtk.MESSAGE_ERROR,gtk.BUTTONS_CLOSE)
        else:
             if (self.txtpathorig.get_text()== self.txtpathmosaic.get_text()):
                 mosaic.on_dialog(self.wdcreatemosaic, "Por favor debe seleccionar una imagen origen y una destino distintas",
                  gtk.MESSAGE_ERROR, gtk.BUTTONS_CLOSE)
             else:
                 self.generate_mosaic()
                 
    def generate_mosaic(self):
        self.processexecute=process.Process(None,self,"create")
        self.res = subprocess.Popen(["metapixel", "--metapixel", self.orig, self.output,
         "--l="+self.mosaic.txtwork, "--cheat="+str(self.cheat), "--width="+str(self.mosaic.width),
         "--height="+str(self.mosaic.width),"--distance="+str(self.distance), "--scale="+str(self.scale) ], stdout=subprocess.PIPE)
        thread=ThreadMeta(self.res)     
        thread.start()
        while thread.isAlive():
            time.sleep(0.09)
            self.processexecute.pgbar.pulse()
            while gtk.events_pending():
                gtk.main_iteration()
        
        if (self.res.returncode!=0):
            self.processexecute.wdprocess.destroy()
            mosaic.on_dialog(self.wdcreatemosaic, "Error: Seleccione un menor tamaño o distancia", gtk.MESSAGE_ERROR,gtk.BUTTONS_CLOSE)
        else:    
            self.processexecute.pgbar.set_fraction(1.0)
            self.processexecute.label1.set_text("Mosáico generado correctamente")
            self.processexecute.wdprocess.set_title("Getapixel - Completado")
                       
            self.processexecute.btok.show()
        
    def destroy(self, widget, data=None):
        
        widget.destroy()
    
    def on_spbtscale_value_changed(self, widget, data=None):
        self.mosaic.scale=widget.get_value_as_int()
        
    
    def on_spbtdistance_value_changed(self, widget, data=None):
        self.mosaic.distance=widget.get_value_as_int()

    def on_spbtcheat_value_changed(self, widget, data=None):
        self.mosaic.cheat=widget.get_value_as_int()
        
    def on_txtpathorig_changed(self, widget, data=None):
        self.mosaic.orig=widget.get_text()
            
            
class ThreadMeta(Thread):
    def __init__(self,res):
        
        self.res=res
        Thread.__init__(self)
        
    def run(self):
        self.res2=self.res.communicate()[0]
        self.result=self.res2
        

