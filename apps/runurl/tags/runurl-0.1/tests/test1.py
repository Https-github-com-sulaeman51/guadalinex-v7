#!/usr/bin/python

# Testing of different urls

import re

urls=("http://cheese","run:cheese","run://cheese","run:///cheese","run:cheese/cake","run:cheese?hack","run:cheese_cake-1")

for u in urls:

# Accepted chars= a-z, 0-9, - _ /

  r=re.match("run:\/{0,2}([a-zA-z0-9_\-\/]+)",u,re.IGNORECASE)
  print u,
  if r:
    print r.group(1)
  else:
    print "No matching"
    