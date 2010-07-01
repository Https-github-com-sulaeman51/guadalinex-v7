# -*- coding: utf-8 -*-
#
# Authors:
#     David Amián Valle (amialinux) <amialinux at gmail>
#
# [es] Modulo enpathia - Módulo que implementa el "actor hardware" para el
#                        dispositivo de accesibilidad enpathia
# [en] enpathia module - Implements hardware actor for enpathia accesibility
#                        hardware
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

import os.path

from deviceactor import PkgDeviceActor
from gettext import gettext as _


class Actor (PkgDeviceActor):
    """ 
    [es] Implementacion de clase Actor para el accesorio de accesibilidad
    enpathia
    --------------------------------------------------------------------------
    [en] Actor class implementation for enpathia hardware accesibility
    """
    __required__ = {'linux.subsystem':'input',
                    'info.product':'Eneso EnPathia'}
    __icon_path__ = os.path.abspath('actors/img/enpathia.png')
    __iconoff_path__ = os.path.abspath('actors/img/enpathiaoff.png')
    __device_title__ = _("Enpathia")
    __device_conn_description__ = _("Enpathia connected")
    __device_disconn_description__ = _("Enpathia disconnected")
    __priority__=5

