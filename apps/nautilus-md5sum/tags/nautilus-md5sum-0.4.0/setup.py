from distutils.core import setup
from DistUtilsExtra.command import *

setup(name='nautilus-md5sum',
    version='0.4.0',
    author='David Amian',
    author_email='amialinux@gmail.com',
    data_files=[('lib/nautilus/extensions-2.0/python/', ['scripts/nautilus-md5sum.py']),
                ('share/nautilus-md5sum/',['data/nautilus-md5sum-notification', 'data/md5.glade']),
                ('share/icons/',['data/md5sum-ico.png'])],
    cmdclass = { "build" : build_extra.build_extra,
        "build_i18n" :  build_i18n.build_i18n,
        "clean": clean_i18n.clean_i18n,
        }
    )


