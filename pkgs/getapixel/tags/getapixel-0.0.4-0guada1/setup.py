from distutils.core import setup
from DistUtilsExtra.command import *

setup(name='getapixel',
    version='0.0.1',
    author='David Amian',
    author_email='amialinux@gmail.com',
    data_files=[('share/getapixel/glade',['data/about.glade','data/createmosaic.glade',
                'data/mosaic.glade', 'data/process.glade',
                'data/selectpaths.glade']),
                ('share/getapixel/', ['src/about.py',
                'src/createmosaic.py','src/mosaic.py','src/process.py',
                'src/selectpath.py','src/sendfile.py']),
                ('share/getapixel/images/',['images/bggetapixel.png']),
                ('share/icons/',['images/getapixel_46x46.png']),
                ('bin/',['src/getapixel']),
                ('share/applications/',['data/getapixel.desktop'])],
    cmdclass = { "build" : build_extra.build_extra,
                }
    )
                
