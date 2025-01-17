#!/usr/bin/python
# -*- coding: utf-8 -*- 
#
# Authors: 
#     Guadalinex developers team
#     Jose Chaso (pchaso) <jose.chaso at gmail>
#
# [es] Modulo hermes_notifier -
# [en] hermes_notifier module -
#
# Copyright (C) 2009 Junta de Andalucía
# 
# ----------------------------[es]----------------------------- 
#
# Este fichero es parte de Detección de Hardware de Guadalinex V6 
# 
# Este programa es software libre: puede redistribuirlo y/o modificarlo bajo 
# los términos de la Licencia Pública General version 3 de GNU según 
# es publicada por la Free Software Foundation.
# 
# Este programa se distribuye con la esperanza de que será útil, pero 
# SIN NINGUNA GARANTÍA, incluso sin la garantías implicitas de 
# MERCANTILIZACION, CALIDAD SATISFACTORIA o de CONVENIENCIA PARA UN PROPÓSITO 
# PARTICULAR. Véase la Licencia Pública General de GNU para más detalles. 
# 
# Debería haber recibido una copia de la Licencia Pública General 
# junto con este programa; si no ha sido así, 
# visite <http://www.gnu.org/licenses/>
# o escriba a la Free Software Foundation, Inc., 
# 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA.
# 
# ----------------------------[en]-----------------------------
# 
# This file is part of Guadalinex V6 Hardware Detection.
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranties of
# MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, visit <http://www.gnu.org/licenses/>
# or write to the Free Software Foundation, Inc., 
# 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA



import gtk
import dbus
import dbus.decorators
import dbus.service
import egg.trayicon
import thread
import gobject
import os
import logging

from gettext import gettext as _
from optparse import OptionParser
from Queue import Queue


class DefaultMessageRender:
    """ 
    [es] 
    -----------------------------------------------------------------------
    [en] 
    """
    def __init__(self):
        pass


    def show_message(self, message, type):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        pstring = ''
        if type == gtk.MESSAGE_INFO:
            pstring = _("Info") + ": "
        elif type == gtk.MESSAGE_WARNING:
            pstring = _("Warning") + ": "
        elif type == gtk.MESSAGE_ERROR:
            pstring = _("Error") + ": "

        print pstring + str(message)


    def ask_message(self, message, type):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        pstring = ''
        if type == gtk.MESSAGE_INFO:
            pstring = _("Ask Info") + ": "
        elif type == gtk.MESSAGE_WARNING:
            pstring = _("Ask Warning") + ": "
        elif type == gtk.MESSAGE_ERROR:
            pstring = _("Ask Error") + ": "

        print pstring + str(message)



class HermesTray (egg.trayicon.TrayIcon):
    """ 
    [es] 
    -----------------------------------------------------------------------
    [en] 
    """
    def __init__(self):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        egg.trayicon.TrayIcon.__init__(self, "VT")
        #self.add(gtk.Label("VT"))
        img = gtk.Image()
        #img.set_from_stock(gtk.STOCK_DIALOG_INFO, gtk.ICON_SIZE_MENU)
        img.set_from_file('img' + os.sep + 'trayicon.png')

        self.add(img)

        self.dlg = None


    def show_message(self, message, msg_type):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        thread.start_new_thread(self.__show_message, (message, msg_type))


    def __show_message (self, message, msg_type):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        self.abort()
        #Mostramos el trayicon
        gtk.gdk.threads_enter()
        self.show_all()
        gtk.gdk.threads_leave()

        gtk.gdk.threads_enter()
        dlg = gtk.MessageDialog(parent = self,
                                type = msg_type,
                                flags = gtk.DIALOG_MODAL,
                                message_format = message,
                                buttons = gtk.BUTTONS_NONE)

        gtk.gdk.threads_leave()


        def timeout():
            """
            [es] 
            -------------------------------------------------------------------
            [en] Timeout handler than hide messagedialog
            """
            dlg.response(0)
            return False # So only is executed once


        def timeout_2():
            """
            [es] 
            -------------------------------------------------------------------
            [en] Timeout handler than hide trayicon
            """
            self.hide_all()
            return False
        
        gtk.gdk.threads_enter()
        gobject.timeout_add(3000, timeout)
        gobject.timeout_add(5000, timeout_2)

        dlg.run()
        dlg.destroy()
        while gtk.events_pending():
            gtk.main_iteration()
        gtk.gdk.threads_leave()


    def show_question(self, question, default = 1):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        #Show trayicon
        gtk.gdk.threads_enter()
        self.show_all()

        dlg = gtk.MessageDialog(parent = self,
                                type = gtk.MESSAGE_QUESTION,
                                flags = gtk.DIALOG_MODAL,
                                message_format = question,
                                buttons = gtk.BUTTONS_YES_NO)

        self.__setup_dialog(dlg)

        def timeout():
            """ 
            [es] 
            -------------------------------------------------------------------
            [en] Timeout handler than hide messagedialog
            """
            if default == 0:
                dlg.response(gtk.RESPONSE_NO)
            else:
                dlg.response(gtk.RESPONSE_YES)
            return False #Only execute once

        def timeout_2():
            """ 
            [es] 
            -------------------------------------------------------------------
            [en] Timeout handler that hide trayicon
            """
            self.hide_all()
            return False
 
        gobject.timeout_add(7000, timeout)
        gobject.timeout_add(9000, timeout_2)

        if dlg.run() == gtk.RESPONSE_YES:
            res = 1 
        else:
            res = 0
        
        dlg.destroy()
        self.hide_all()

        while gtk.events_pending():
            gtk.main_iteration()

        gtk.gdk.threads_leave()
        return res


    def show_entry(self, message):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        """
        Shows a dialig with a text entry so the user can
        input any data

        Returns the text introduced by the user
        """
        gtk.gdk.threads_enter()
        self.show_all()

        dlg = gtk.Dialog( _("Input"),
                parent = self,
                flags = gtk.DIALOG_MODAL,
                buttons = (gtk.STOCK_APPLY, gtk.RESPONSE_OK))

        entry = gtk.Entry()

        dlg.vbox.pack_start(gtk.Label(message))
        dlg.vbox.pack_start(entry)
        dlg.vbox.show_all()

        self.__setup_dialog(dlg)

        def timeout():
            """
            Timeout handler than hide messagedialog
            """
            dlg.response(gtk.RESPONSE_CANCEL)
            return False #Only execute once

        def timeout_2():
            """
            Timeout handler than hide trayicon
            """
            self.hide_all()
            return False
        
        gobject.timeout_add(10000, timeout)
        gobject.timeout_add(11000, timeout_2)

        dlg.run() 
        res =  entry.get_text()
        
        dlg.destroy()
        self.hide_all()

        while gtk.events_pending():
            gtk.main_iteration()

        gtk.gdk.threads_leave()
        return res


    def abort(self):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        gtk.gdk.threads_enter()
        try:
            self.dlg.destroy()
        except Exception:
            pass
        gtk.gdk.threads_leave()


    def __setup_dialog(self, dialog):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        dialog.set_position(gtk.WIN_POS_CENTER_ON_PARENT)
        dialog.set_decorated(False) #Sin borde
        dialog.stick() #The message dialog shows in all workspaces
        dialog.set_keep_above(True) #Se mantiene en primer plano
        dialog.set_focus_on_map(False)
        dialog.modify_bg(gtk.STATE_NORMAL, gtk.gdk.Color(65500, 65535, 48573))

        self.dlg = dialog


class HermesTray2:
    """
    [es] 
    -----------------------------------------------------------------------
    [en] 
    """
    BACKGROUND_COLOR = gtk.gdk.Color(65500, 65535, 48573)

    def __init__(self):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        self.trayicon = egg.trayicon.TrayIcon("VT")
        img = gtk.Image()
        img.set_from_file('img' + os.sep + 'trayicon.png')

        self.trayicon.add(img)
        
        self.main_window = gtk.Dialog(parent = self.trayicon, flags = gtk.DIALOG_MODAL)
        self.__setup_dialog(self.main_window)

        #Delete all children
        for child in self.main_window.vbox.get_children():
            self.main_window.vbox.remove(child)

        self.box = self.main_window.vbox


        self.box.set_resize_mode(gtk.RESIZE_IMMEDIATE)


    def show_message(self, message, msg_type):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        thread.start_new_thread(self.__show_message, (message, msg_type))


    def ask_message(self, message, msg_type):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        return self.__show_message(message, msg_type, True)


    def __show_message (self, message, msg_type, ask = False):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        gtk.threads_enter()
        dlg = gtk.MessageDialog(parent = self.main_window,
                                type = msg_type,
                                flags = gtk.DIALOG_MODAL,
                                message_format = message,
                                buttons = gtk.BUTTONS_NONE)

        #self.__setup_dialog(dlg)
        
        vbox = dlg.vbox
        dlg.remove(vbox)

        #Prepare Close/Execute button
        hbox = gtk.HBox()
        tooltips = gtk.Tooltips()
        tooltips.enable()
        if not ask:
            close_button = gtk.Button(stock = gtk.STOCK_CLOSE)
            close_button.connect("clicked", lambda *args: self.__remove_message(vbox))
            tooltips.set_tip(close_button, _("Close message"))
        else:
            queue = Queue()

            def execute(*args):
                queue.put(1)
                self.__remove_message(vbox)

            close_button = gtk.Button(stock = gtk.STOCK_EXECUTE)
            close_button.connect("clicked", execute)
            tooltips.set_tip(close_button, _("Run action message"))

           
        close_button.modify_bg(gtk.STATE_NORMAL, HermesTray2.BACKGROUND_COLOR)
        button_vbox = close_button.child.child
        button_label = button_vbox.get_children()[-1]
        button_label.set_text("")

        hbox.pack_end(close_button, False, False)
        hbox.show_all()
        vbox.pack_start(hbox)

        self.box.pack_end(vbox)
        vbox.show_all()
        gtk.threads_leave()

        def timeout():
            """
            [es] 
            -------------------------------------------------------------------
            [en] Hide messagedialog
            """
            if ask:
                queue.put(0)

            self.__remove_message(vbox)
            return False #Only execute once


        def timeout_2():
            """
            [es] 
            -------------------------------------------------------------------
            [en] 
            """
            """
            Hide trayicon
            """
            self.trayicon.hide_all()
            return False
        
        gtk.gdk.threads_enter()
        if ask:
            interval = 4000
            interval_2 = 6000
        else:
            interval = 3000
            interval_2 = 5000

        gobject.timeout_add(interval, timeout)
        gobject.timeout_add(interval_2, timeout_2)

        self.trayicon.show_all()

        self.__setup_dialog(self.main_window)
        self.main_window.show_all()

        gtk.gdk.threads_leave()

        if ask:
            while queue.empty():
                gtk.gdk.threads_enter()
                gtk.main_iteration()
                gtk.gdk.threads_leave()
            return queue.get()


    def __remove_message(self, vbox):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        if vbox in self.box.get_children():
            self.box.remove(vbox)
            vbox.destroy()
            if len(self.box.get_children()) == 0:
                self.main_window.hide_all()


    def __setup_dialog(self, dialog):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        dialog.set_gravity(gtk.gdk.GRAVITY_SOUTH_EAST) 
        dialog.set_resizable(False)

        dialog.set_focus_on_map(False)
        dialog.set_position(gtk.WIN_POS_CENTER_ON_PARENT)
        dialog.set_decorated(False) #Sin borde
        dialog.stick() #Message dialog shows in all workspaces
        dialog.set_keep_above(True) #Se mantiene en primer plano
        dialog.modify_bg(gtk.STATE_NORMAL, HermesTray2.BACKGROUND_COLOR)

        self.dlg = dialog

class TrayObject(dbus.service.Object):
    """ 
    [es] 
    -----------------------------------------------------------------------
    [en] 
    """
    def __init__(self, service, message_render = DefaultMessageRender()):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        dbus.service.Object.__init__(self, service,
                                     "/org/guadalinex/HermesObject")
        self.message_render = message_render
        self.logger = logging.getLogger()
        self.logger.debug(_("HermesObject started"))


    @dbus.decorators.method("org.guadalinex.IHermesNotifier")
    def show_info(self, message):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] This method shows a info message
        """
        self.logger.info(_("Show Info") + ": " + message)
        return self.message_render.show_message(message, gtk.MESSAGE_INFO)

    @dbus.decorators.method("org.guadalinex.IHermesNotifier")
    def ask_info(self, message):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        self.logger.info(_("Ask Info") + ": " + message)
        return self.message_render.ask_message(message, gtk.MESSAGE_INFO)


    @dbus.decorators.method("org.guadalinex.IHermesNotifier")
    def show_warning(self, message):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] This method shows a info message
        """
        self.logger.info(_("Show Warning") + ": " + message)
        return self.message_render.show_message(message, gtk.MESSAGE_WARNING)


    @dbus.decorators.method("org.guadalinex.IHermesNotifier")
    def ask_warning(self, message):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        self.logger.info(_("Ask Warning") + ": " + message)
        return self.message_render.ask_message(message, gtk.MESSAGE_WARNING)


    @dbus.decorators.method("org.guadalinex.IHermesNotifier")
    def show_error(self, message):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] This method shows a info message
        """
        self.logger.info(_("Show Error") +  ": " + message)
        return self.message_render.show_message(message, gtk.MESSAGE_ERROR)

    @dbus.decorators.method("org.guadalinex.IHermesNotifier")
    def ask_error(self, message):
        """ 
        [es] 
        -------------------------------------------------------------------
        [en] 
        """
        self.logger.info(_("Ask Error") + ": " + message)
        return self.message_render.ask_message(message, gtk.MESSAGE_ERROR)



def main():
    """ 
    [es] 
    -----------------------------------------------------------------------
    [en] Configure options
    """
    
    parser = OptionParser(usage = 'usage: %prog [options]')
    parser.set_defaults(debug = False)

    parser.add_option('-d', '--debug', 
            action = 'store_true',
            dest = 'debug',
            help = _('Start in debug mode'))

    (options, args) = parser.parse_args()
    
    if options.debug:
        level = logging.DEBUG
    else:
        level = logging.INFO

    logging.basicConfig(level = level,
            format='%(asctime)s %(levelname)s %(message)s',
                    filename='/var/tmp/hermes-notifier.log',
                    filemode='a')

    logger = logging.getLogger()

    tray = HermesTray2()
    session_bus = dbus.SessionBus()
    service = dbus.service.BusName("org.guadalinex.Hermes", session_bus)
    TrayObject(service, tray)

    gtk.gdk.threads_init()
    logger.info(_("Hermes Notifier Started"))
    gtk.main()


if __name__ == "__main__":
    main()
