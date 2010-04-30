#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
#       about.py
#       
#        Copyright 2009 D. Amian <amialinux@gmail.com>
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
gtk.glade.textdomain("getapixel")
gtk.glade.bindtextdomain("getapixel")

class About():
    
    def __init__(self):
    
        self.glade = gtk.glade.XML(mosaic.PATH+"glade/about.glade")
        self.glade.signal_autoconnect(self)
        self.wdabout = self.glade.get_widget("wdabout")
        self.wdabout.connect("destroy", self.destroy)
        self.wdabout.set_icon_from_file(mosaic.PATH_ICON+"getapixel_46x46.png")
        self.wdabout.set_logo(gtk.gdk.pixbuf_new_from_file(mosaic.PATH+"images/bggetapixel.png"))
        self.wdabout.run()
        self.wdabout.destroy()

    
    def destroy(self, widget, data=None):
        widget.destroy()
