#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
#       mosaic.py
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
import selectpath
import createmosaic
import about
import os
import ConfigParser
#Global
PATH= "/usr/share/getapixel/"
PATH_ICON="/usr/share/icons/"

class Mosaic:
    
    def __init__(self):
        self.fileOptions = os.path.expanduser("~") + "/.getapixel.cfg"
        self.glade = gtk.glade.XML(PATH+"glade/mosaic.glade")
        self.glade.signal_autoconnect(self)
        self.wdmosaic = self.glade.get_widget("wdmosaic")
        self.loadFail=self.loadconfig()
        if self.loadFail:
            self.loaddefault()
        self.wdmosaic.connect("destroy", self.destroy)
        self.wdmosaic.set_icon_from_file(PATH_ICON+"getapixel_46x46.png")
        self.wdmosaic.show_all()

    def main(self):
        gtk.main()
      
    def on_btexit_clicked(self,widget,data=None):
        self.saveConfig()
        gtk.main_quit()
        
    def destroy(self, widget, data=None):
        self.saveConfig()
        gtk.main_quit()
      
    def saveConfig(self):
        if not self.loadFail:
            if os.path.exists(self.fileOptions):
                os.remove(self.fileOptions)
            mosaicconfig = "[SelectPath]\n"
            mosaicconfig += "txtphotos = %s\n" % self.txtphotos
            mosaicconfig += "txtwork = %s\n" % self.txtwork
            mosaicconfig += "recursive = %s\n" % self.recursive
            mosaicconfig += "width = %s\n" % self.width
            mosaicconfig += "height = %s\n" % self.height
            mosaicconfig += "[CreateMosaic]\n"
            mosaicconfig += "scale = %s\n" % self.scale
            mosaicconfig += "distance = %s\n" % self.distance
            mosaicconfig += "cheat = %s\n" % self.cheat
            mosaicconfig += "orig = %s\n" % self.orig
            config_file = open(self.fileOptions, "w")
            config_file.write(mosaicconfig)
            config_file.close()
    
    def on_btpath_clicked(self, widget, data=None):
        path=selectpath.SelectPath(self)
    
    def loaddefault(self):
        self.txtphotos = ""
        self.txtwork = ""
        self.recursive = False
        self.width = 50
        self.height = 50
        self.scale= 2
        self.distance= 20  
        self.cheat= 10
        self.orig=""
        self.output=""
        
    def on_btmosaic_clicked(self, widget, data=None):
        boolmxt=False
        if not self.txtwork=="":
            for filename in os.listdir(self.txtwork):
                splitpath = filename.split('.')
                if splitpath[len(splitpath)-1] == "mxt":
                    boolmxt=True
         
        if not boolmxt:
            on_dialog(self.wdmosaic, "Por favor debe seleccionar un directorio donde se hayan "
            +"generado con anterioridad las piezas", gtk.MESSAGE_ERROR, gtk.BUTTONS_CANCEL)
                  
        else:
            cmosaic=createmosaic.CreateMosaic(self)    

    def on_btabout_clicked(self, widget, data=None):
        vbabout=about.About()
        
    def loadconfig(self):
        if os.path.exists(self.fileOptions):
            cfg = ConfigParser.SafeConfigParser()
            cfg.readfp(file(self.fileOptions))
            try:
                self.txtphotos = cfg.get("SelectPath", "txtphotos")
                self.txtwork = cfg.get("SelectPath", "txtwork")
                if cfg.get("SelectPath", "recursive")=="True":
                    self.recursive = True
                else:
                    self.recursive = False
                self.width = int(cfg.get("SelectPath", "width"))
                self.height = int(cfg.get("SelectPath", "height"))
                self.scale = int(cfg.get("CreateMosaic", "scale"))
                self.distance = int(cfg.get("CreateMosaic", "distance"))
                self.cheat = int(cfg.get("CreateMosaic", "cheat"))
                self.orig=cfg.get("CreateMosaic", "orig")
                return False
            except (ConfigParser.NoOptionError, ConfigParser.NoSectionError):
                on_dialog(self.wdmosaic, "El fichero de configuraciones esta erroneo, "+
                "se usará la configuración por defecto", gtk.MESSAGE_ERROR,gtk.BUTTONS_CLOSE)
                
                return True
        else:
            self.loaddefault()
            return False
        

def on_dialog(parent, text, type, buttons):
    md = gtk.MessageDialog(parent, gtk.DIALOG_DESTROY_WITH_PARENT,
                type, buttons, text)
    if type==gtk.MESSAGE_ERROR:
        md.set_title("Getapixel - Error")
        md.set_icon_from_file("/usr/share/icons/gnome/16x16/actions/gtk-stop.png")
    elif type==gtk.MESSAGE_INFO:
        md.set_title("Getapixel - Info")
        md.set_icon_from_file(PATH_ICON+"getapixel_46x46.png")
    md.run()
    md.destroy() 


if __name__ == "__main__":
    mosaic=Mosaic()
    mosaic.main()
                            
