#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
#       process.py
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
import time
import mosaic

class Process():
    def __init__(self,selectpath,createm,wd):
        self.selectpath=selectpath
        self.createm=createm
        self.wd=wd
        self.glade = gtk.glade.XML(mosaic.PATH+"glade/process.glade")
        self.glade.signal_autoconnect(self)
        self.wdprocess = self.glade.get_widget("wdprocess")
        self.wdprocess.set_title("Getapixel - Procesando...")
        self.pgbar = self.glade.get_widget("pgbar")
        self.btok = self.glade.get_widget("btok")
        self.label1 = self.glade.get_widget("label1")
        self.wdprocess.connect("destroy", self.on_btok_clicked)
        self.wdprocess.set_icon_from_file(mosaic.PATH_ICON+"getapixel_46x46.png")
        self.wdprocess.show_all()
        self.btok.hide()
        
       
    def on_btok_clicked(self, widget, data=None):
        if (self.wd=="prepare"):       
            self.selectpath.wdselectpaths.destroy()
        else:
            self.createm.wdcreatemosaic.destroy()
        self.wdprocess.destroy()    
    
    def destroy(self, widget, data=None):
        widget.destroy()
