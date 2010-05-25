from distutils.core import setup
from DistUtilsExtra.command import *

setup(name='nautilus-fontinstall',
    version='0.1.0',
    author='David Amian',
    author_email='amialinux@gmail.com',
    packages=['nautilus-fontinstall'],
    data_files=[('lib/nautilus/extensions-2.0/python/', ['nautilus-fontinstall/nautilus-fontinstall.py', 'nautilus-fontinstall/fontinstall.glade']),
                ('share/nautilus-fontinstall/',['nautilus-fontinstall/nautilus-fontinstall-notification'])]
    cmdclass = { "build" : build_extra.build_extra,
        "build_i18n" :  build_i18n.build_i18n,
        "clean": clean_i18n.clean_i18n, 
        }
    )

