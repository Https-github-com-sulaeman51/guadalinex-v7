# -*- coding: utf-8 -*-

#Módulo gempluscardreader- Módulo que implementa el "actor hardware" para los
#lectores de tarjetas Gemplus GemPC Twin.
#
# Authors:
#     David Amián Valle <amialinux@gmail.com
#
# [es] Modulo gempluscardreader - Implementación del "actor hardware" para
#         lectores de tarjetas Gemplus GemPC Twin
# [en] gempluscardreader Module - Gemplus GemPC Twin cardreader devices Actor
# class implementation
#
# Copyright (C) 2009 Junta de Andalucía
#
# ----------------------------[es]---------------------------------------------
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
# ----------------------------[en]---------------------------------------------
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

import commands
import os
import os.path

from deviceactor import PkgDeviceActor
from utils.pkginstaller import PkgInstaller
from utils import get_sudo
from gettext import gettext as _

CERTMANAGER_CMD = '/usr/bin/certmanager.py'


class Actor(PkgDeviceActor):
    """
    [es] Implementación de la clase Actor para dispositivos lectores de
            tarjetas Gemplus GemPC Twin.
    ---------------------------------------------------------------------------
    [en]  Gemplus GemPC Twin cardreader devices Actor class implementation
    """
    __required__ = {
            "info.subsystem": "usb_device",
            "usb_device.vendor_id":0x8E6,
            "usb_device.product_id":0x3437}

    __icon_path__  = os.path.abspath('actors/img/gempctwin.png')
    __iconoff_path__ = os.path.abspath('actors/img/gempctwinoff.png')
    __device_title__ = _("Gemplus GemPC Twin")
    __device_conn_description__ = _("Card reader detected")
    __device_disconn_description__ = _("Card reader disconnected")

    def on_added(self):
        os.system("sudo /etc/init.d/pcscd stop")
        os.system("sudo /etc/init.d/pcscd start")
        actions = {}
        def configure_dnie():
            os.system('%s --install-dnie' % CERTMANAGER_CMD)

        def configure_ceres():
            os.system('%s --install-ceres' % CERTMANAGER_CMD)

        if os.path.exists(CERTMANAGER_CMD):
            actions[_("Configure DNIe")] = configure_dnie
            actions[_("Configure FNMT-Ceres card")] = configure_ceres
        
        os.system("sudo /etc/init.d/pcscd stop")
        os.system("sleep 2")
        os.system("sudo /etc/init.d/pcscd start")

        def add_user_to_scard():
            import pwd
            # The os.getlogin() raises OSError: [Errno 25]
            # Moved to getpwuid
            user = pwd.getpwuid(os.geteuid())[0]
            # [es] Obtenemos acceso en modo administrador
            # [en] get root access
            if get_sudo():
                cmd = '/usr/bin/gksudo /usr/sbin/adduser %s scard' % user
                status, output = commands.getstatusoutput(cmd)
                self.msg_render.show_info(_('Session restart needed'),
                                          _('You must restart your session to apply the changes'))

        status, output = commands.getstatusoutput('/usr/bin/groups')
        if 'scard' not in output:
            actions[_("Add user to scard group")] = add_user_to_scard

        self.msg_render.show(self.__device_title__, 
                             self.__device_conn_description__,
                             self.__icon_path__, actions=actions)

