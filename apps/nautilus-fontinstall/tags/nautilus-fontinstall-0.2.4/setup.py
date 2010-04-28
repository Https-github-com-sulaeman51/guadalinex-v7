from distutils.core import setup
from DistUtilsExtra.command import *

setup(name='nautilus-fontinstall',
    version='0.2.3',
    author='David Amian',
    author_email='amialinux@gmail.com',
    data_files=[('lib/nautilus/extensions-2.0/python/', ['scripts/nautilus-fontinstall.py']),
                ('share/nautilus-fontinstall/',['data/nautilus-fontinstall-notification', 'data/fontinstall.glade']),
                ('share/icons/',['data/fontinstall-ico.png'])],
    cmdclass = { "build" : build_extra.build_extra,
        "build_i18n" :  build_i18n.build_i18n,
        "clean": clean_i18n.clean_i18n, 
        }
    )

