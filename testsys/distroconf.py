# -*- coding: utf-8 -*-
# Configuración útil para master.cfg

############
# SVN 
############

# URL del subversion sobre el que hacer polling.
svn = "http://svn.emergya.info/svn/ggv6"

# Tiempo de polling, en segundos, sobre el subversion para detectar cambios.
polling_time = 5

# Nombre del directorio que contendrá las apps. 
# Las apps son ramas de subversion con tags y trunk y que se construyen 
# con debuild. Solo se chequeará la última versión el tag sobre la que se
# hayan aplicado commits. 
apps_dir = "apps"

# Nombre del directorio que contendrá los metapkgs.
# Los metapkgs son ramas de subversion a construir con gcs_build.
metapkgs_dir = "metapkgs"

# Nombre de la subrama trunk.
trunk_dir = "trunk"

# Nombre de la subrama tags.
tags_dir = "tags"

# Nombre de la subrama gcs.
gcs_dir = "gcs"

# Lista de nombre de las apps. El nombre debe coincidir con la rama de 
#subversion que contiene la app. La inclusión en esta lista de una nueva app
#hace que buildbot la gestione automáticamente.
#apps=[]
apps=[
#        "example",
	"abanq",
	"casper-guada",
	"lemurae",
	"guadalinfo-ldap-admin",
	"guadalinfo-backup-manager",
	"guada-ubiquity",
	"grub",
	"indicator-session",
	"linux-image",
	"linux-meta",
	"medusa-client",
	"medusa-server",
	"mount-systray",
	"hermeshardware",
	"guadalinex-eadmin",
	"vaguada",
	"detacher",
	"commiecc",
        "ocrfeeder",
        "pycaptive",
	"diagnostic-report",
	"synaptic",
]

# Lista de nombre de los metapkgs. El nombre debe coincidir con la rama de 
# subversion que contiene el metapkg. La inclusión en esta lista de un nuevo 
# metapkg hace que buildbot lo gestione automáticamente.
metapkgs = [
	"guadalinfo-artwork",
	"guadalinfo-base",
	"guadalinfo-base-conf",
	"guadalinfo-client",
	"guadalinfo-client-conf",
	"guadalinfo-desktop",
	"guadalinfo-desktop-conf",
	"guadalinfo-server",
	"guadalinfo-server-conf",
]


# Building 
############

# Tiempo de cortesía, en segundos,  entre que se detecta un cambio en el último
# tag de la app y se comienza el proceso de integración.
app_timer = 5

# Tiempo de cortesía, en segundos, entre que se detecta un cambio en el metapkg
# y se comienza el proceso de integración.
metapkg_timer = 5

# Gensys es ejecutado una vez al día. Defínase aquí la hora concreta de lanzamienzo.
gensys_time = "00:00"

# Indica si debemos abortar el proceso de integración ante errores 
# de lintian.
halt_on_lintian_error = False

# Indica si debemos abortar el proceso de integración ante errores
# de unittests.
halt_on_unittest_error = True


################
# Gensys
################

repo_update_dir = "/var/gensys/deb-repositories/karmic-pkgs"
repo_update_distro = "ggv6-karmic"

# Directorio donde se subirán automáticamente los paquetes construidos.
upload_dir = "/var/gensys/deb-repositories/karmic-pkgs"
codename = "ggv6-karmic"
repo_dir = "/var/gensys/deb-repositories/karmic-derivative-repo"

# TODO: Esto debería ir en una clase a FileUpload a parte
rawimage = "/var/gensys/live-helper/ggv6-karmic/binary.iso"
clientftpimage = "/var/gensys/isos/karmic-guadalinfo-client-desktop-i386.iso"
serverftpimage = "/var/gensys/isos/karmic-guadalinfo-server-desktop-i386.iso"

# Path común para la ejecución de los scripts gensys
path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Script para generar el repositorio 'derivative' y variables de entorno
# que necesite para su ejecución
derivative = "update-derivative-repository"
derivative_env = {
    "PATH" : path
}

# Script live-helper y variables de entorno que necesite para su ejecución
livehelper_path = "/var/gensys/live-helper/ggv6-karmic"
livehelper = "sudo /var/gensys/live-helper/ggv6-karmic/build.sh"
livehelper_env = { 
    "PATH" : path
}

# pdebuild custom commands
pdebuild = "pdebuild --configfile /var/gensys/svn-checkout/gensys/gensys-misc-config/pbuilderrc-karmic"
