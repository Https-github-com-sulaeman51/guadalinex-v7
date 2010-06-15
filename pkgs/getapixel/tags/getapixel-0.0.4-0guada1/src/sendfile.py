#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
#       sendfile.py
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
import mosaic
import gettext
gettext.install("getapixel")
gtk.glade.textdomain("getapixel")
gtk.glade.bindtextdomain("getapixel")


class SendFile:
    def __init__(self, vbmosaic, selectpath, createm, typepath, type, title):
        self.mosaic=vbmosaic
        self.selectpath=selectpath
        self.createm=createm
        self.typepath=typepath
        
        self.filechooser=gtk.FileChooserDialog(_("Open.."),
                               None,
                               gtk.FILE_CHOOSER_ACTION_OPEN,
                               (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL,
                                gtk.STOCK_OPEN, gtk.RESPONSE_OK))

        
        self.filechooser.set_action(type)
        self.filechooser.set_title(title)
        
        self.filechooser.set_default_response(gtk.RESPONSE_OK)
        if typepath=="orig":
            filter = gtk.FileFilter()
            filter.set_name(_("Images file"))
            filter.add_mime_type("image/png")
            filter.add_mime_type("image/jpeg")
            filter.add_pattern("*.png")
            filter.add_pattern("*.jpg")
            self.filechooser.add_filter(filter)
            
            filter = gtk.FileFilter()
            filter.set_name(_("All files"))
            filter.add_pattern("*")
            self.filechooser.add_filter(filter)
            self.preview = gtk.Image()
            self.filechooser.set_preview_widget(self.preview)
            self.filechooser.connect("update-preview", update_preview_cb, self.preview)



            
        self.filechooser.set_icon_from_file(mosaic.PATH_ICON+"getapixel_46x46.png")
        
        
        response=self.filechooser.run()
        
        if response == gtk.RESPONSE_OK:
            if self.typepath=="work":
                self.selectpath.txtpathwork.set_text(self.filechooser.get_filenames()[0])
                self.mosaic.txtwork=self.filechooser.get_filenames()[0]
            elif self.typepath=="photos":
                self.selectpath.txtpathphotos.set_text(self.filechooser.get_filenames()[0])
                self.mosaic.txtphotos=self.filechooser.get_filenames()[0]
            elif self.typepath=="orig":
                self.createm.txtpathorig.set_text(self.filechooser.get_filenames()[0])
                self.mosaic.orig=self.filechooser.get_filenames()[0]
            elif self.typepath=="mosaic":
                self.createm.txtpathmosaic.set_text(self.filechooser.get_filenames()[0])
                
        
        self.filechooser.destroy()    
         
         
def update_preview_cb(file_chooser, preview):
    filename = file_chooser.get_preview_filename()
    try:
        pixbuf = gtk.gdk.pixbuf_new_from_file_at_size(filename, 128, 128)
        preview.set_from_pixbuf(pixbuf)
        have_preview = True
    except:
        have_preview = False
    file_chooser.set_preview_widget_active(have_preview)
    return


        
    
