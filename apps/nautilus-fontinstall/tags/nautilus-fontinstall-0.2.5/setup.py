from distutils.core import setup
from DistUtilsExtra.command import *

setup(name='nautilus-fontinstall',
    version='0.2.2-0guada1',
    author='David Amian',
    author_email='amialinux@gmail.com',
    packages=['nautilus-fontinstall'],
    data_files=[('lib/nautilus/extensions-2.0/python/', ['nautilus-fontinstall/nautilus-fontinstall.py']),
                ('share/nautilus-fontinstall/',['nautilus-fontinstall/nautilus-fontinstall-notification', 'nautilus-fontinstall/fontinstall.glade'])],
    cmdclass = { "build" : build_extra.build_extra,
        "build_i18n" :  build_i18n.build_i18n,
        "clean": clean_i18n.clean_i18n, 
        }
    )

