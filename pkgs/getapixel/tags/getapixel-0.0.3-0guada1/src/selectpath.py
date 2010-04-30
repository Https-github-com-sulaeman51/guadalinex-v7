#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
#       selectpath.py
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
# We use the 2.0 gtk version
pygtk.require('2.0')
import gtk.glade
import sendfile
import os
import subprocess
import process
import time
import mosaic
from threading import Thread



class SelectPath():
    def __init__(self, vbmosaic):
        self.mosaic=vbmosaic
        self.glade = gtk.glade.XML(mosaic.PATH+"glade/selectpaths.glade")
        self.glade.signal_autoconnect(self)
        self.wdselectpaths = self.glade.get_widget("wdselectpaths")
        self.txtpathphotos = self.glade.get_widget("txtpathphotos")
        self.txtpathwork = self.glade.get_widget("txtpathwork")
        self.chbtrecursive = self.glade.get_widget("chbtrecursive")
        self.spbtwidth = self.glade.get_widget("spbtwidth")
        self.spbtheight = self.glade.get_widget("spbtheight")
        self.wdselectpaths.connect("destroy", self.destroy)
        self.wdselectpaths.set_icon_from_file(mosaic.PATH_ICON+"getapixel_46x46.png")
        self.txtpathphotos.set_text(self.mosaic.txtphotos)
        self.txtpathwork.set_text(self.mosaic.txtwork)
        self.chbtrecursive.set_active(self.mosaic.recursive)
        self.spbtwidth.set_value(self.mosaic.width)
        self.spbtheight.set_value(self.mosaic.height)
        self.wdselectpaths.show_all()
        
        

    

    def destroy(self, widget, data=None):
        
        widget.destroy()
      
    def on_btSelect1_clicked(self, widget, data=None):
        chooser=sendfile.SendFile(self.mosaic,self,None,"photos",gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER, "Seleccione la ruta de fotos")
    
    def on_btSelect2_clicked(self, widget, data=None):
        chooser=sendfile.SendFile(self.mosaic,self,None,"work",gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER, "Seleccione la ruta de trabajo")
        
    def on_btcancel_clicked(self, widget, data=None):
        self.wdselectpaths.destroy()
        
    def on_btok_clicked(self, widget, data=None):
        generate_pieces = False
        fail=False
        if (self.txtpathphotos.get_text_length() >0 and self.txtpathwork.get_text_length() > 0 and
        self.txtpathwork.get_text()== self.txtpathphotos.get_text()):
            mosaic.on_dialog(self.wdselectpaths, "Por favor seleccione directorios diferentes", gtk.MESSAGE_ERROR, gtk.BUTTONS_CLOSE)
            fail=True
        else:
            if self.txtpathphotos.get_text_length() <= 0:
                generate_pieces = False
                if self.txtpathwork.get_text_length() <= 0:
                    mosaic.on_dialog(self.wdselectpaths, "Por favor seleccione un directorio de trabajo", gtk.MESSAGE_ERROR, gtk.BUTTONS_CLOSE)
                    fail=True
                else: 
                    if self.check_path_index(self.txtpathwork.get_text()):
                        generate_pieces = False
                        
                    else:
                        mosaic.on_dialog(self.wdselectpaths,
                        "Por favor seleccione un directorio de trabajo con las piezas de mosaico", gtk.MESSAGE_ERROR, gtk.BUTTONS_CLOSE)
                        fail=True
            else:
                generate_pieces = True
                if self.txtpathwork.get_text_length() <= 0:
                    mosaic.on_dialog(self.wdselectpaths, "Por favor seleccione un directorio de trabajo", gtk.MESSAGE_ERROR, gtk.BUTTONS_CLOSE)
                    fail=True
                else: 
                    if self.check_path_index(self.txtpathwork.get_text()):
                        if self.question_generate():
                            generate_pieces = True
                        else:
                            generate_pieces = False
                    else:
                        generate_pieces = True
        
        self.mosaic.txtphotos = self.txtpathphotos.get_text()
        self.mosaic.txtwork = self.txtpathwork.get_text()
        self.mosaic.recursive = self.chbtrecursive.get_active()
        self.mosaic.width = self.spbtwidth.get_value_as_int()
        self.mosaic.height = self.spbtheight.get_value_as_int()
        if not fail:
            if generate_pieces:   
                #self.res = subprocess.Popen(["metapixel", "--width="+self.mosaic.width, "--height="+self.mosaic.width])
                self.execute_pieces()
            
            else:
                self.wdselectpaths.destroy()             
        
    def execute_pieces(self):
        self.processexecute=process.Process(self,None,"prepare")
        if self.mosaic.recursive:
            self.res = subprocess.Popen(["metapixel-prepare","-r","--width="+str(self.mosaic.width),
            "--height="+str(self.mosaic.width),self.mosaic.txtphotos,self.mosaic.txtwork ],stdout=subprocess.PIPE)
        else:
            self.res = subprocess.Popen(["metapixel-prepare", "--width="+str(self.mosaic.width),
            "--height="+str(self.mosaic.width), self.mosaic.txtphotos,self.mosaic.txtwork ], stdout=subprocess.PIPE)
        thread=ThreadMeta(self.res)     
        thread.start()
        while thread.isAlive():
            time.sleep(0.09)
            self.processexecute.pgbar.pulse()
            while gtk.events_pending():
                gtk.main_iteration()
        
        self.processexecute.pgbar.set_fraction(1.0)
        self.processexecute.label1.set_text("Mosáico preparado correctamente")
        self.processexecute.wdprocess.set_title("Getapixel - Completado")
        self.processexecute.btok.show()         
    
    def question_generate(self):
        label = gtk.Label("Ya se han generado las piezas en el directorio de trabajo, ¿desea regenerar?")
        dialog = gtk.Dialog("Aviso",
                   None,
                   gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT,
                   (gtk.STOCK_CANCEL, gtk.RESPONSE_REJECT,
                    gtk.STOCK_OK, gtk.RESPONSE_ACCEPT))
        dialog.vbox.pack_start(label)
        label.show()
        dialog.set_icon_from_file(mosaic.PATH_ICON+"getapixel_46x46.png")
        response = dialog.run()
        dialog.destroy()
        if response == gtk.RESPONSE_REJECT:
            return False
        else:
            return True

                        
    def check_path_index(self, path):
        for filename in os.listdir(path):
            splitpath = filename.split('.')
            if splitpath[len(splitpath)-1] == "mxt":
                return True
        return False        

    def on_spbtwidth_value_changed(self, widget, data=None):
        self.mosaic.width=widget.get_value_as_int()
        
    def on_spbtheight_value_changed(self, widget, data=None):
        self.mosaic.height=widget.get_value_as_int()

    def on_txtpathwork_changed(self, widget, data=None):
        self.mosaic.txtwork=widget.get_text()
        
    def on_txtpathphotos_changed(self, widget, data=None):
        self.mosaic.txtphotos=widget.get_text()  
            
class ThreadMeta(Thread):
    def __init__(self,res):
        
        self.res=res
        Thread.__init__(self)
        
    def run(self):
        self.res2=self.res.communicate()[0]
        self.result=self.res
        
