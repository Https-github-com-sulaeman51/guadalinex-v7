# MetaRelease.py 
#  
#  Copyright (c) 2004,2005 Canonical
#  
#  Author: Michael Vogt <michael.vogt@ubuntu.com>
# 
#  This program is free software; you can redistribute it and/or 
#  modify it under the terms of the GNU General Public License as 
#  published by the Free Software Foundation; either version 2 of the
#  License, or (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
#  USA

import thread
import urllib2
import httplib
import os
import string
import apt_pkg
import time
import sys
import rfc822
from ConfigParser import ConfigParser
from subprocess import Popen,PIPE

from utils import *

class Dist(object):
    def __init__(self, name, version, date, supported):
        self.name = name
        self.version = version
        self.date = date
        self.supported = supported
        self.releaseNotesURI = None
        self.upgradeTool = None
        self.upgradeToolSig = None

class MetaReleaseCore(object):
    """
    A MetaReleaseCore object astracts the list of released 
    distributions. 
    """

    DEBUG = "DEBUG_UPDATE_MANAGER" in os.environ

    # some constants
    CONF = "/etc/update-manager/release-upgrades"
    CONF_METARELEASE = "/etc/update-manager/meta-release"

    def __init__(self, 
                 useDevelopmentRelease=False, 
                 useProposed=False,
                 forceLTS=False):
        self._debug("MetaRelease.__init__() useDevel=%s useProposed=%s" % (useDevelopmentRelease, useProposed))
        # information about the available dists
        self.downloading = True
        self.new_dist = None
        self.current_dist_name = get_dist()
        self.no_longer_supported = None

        # default (if the conf file is missing)
        self.METARELEASE_URI = "http://changelogs.ubuntu.com/meta-release"
        self.METARELEASE_URI_LTS = "http://changelogs.ubuntu.com/meta-release-lts"
        self.METARELEASE_URI_UNSTABLE_POSTFIX = "-development"
        self.METARELEASE_URI_PROPOSED_POSTFIX = "-development"

        # check the meta-release config first
        parser = ConfigParser()
        if os.path.exists(self.CONF_METARELEASE):
            parser.read(self.CONF_METARELEASE)
            # make changing the metarelease file and the location
            # for the files easy
            if parser.has_section("METARELEASE"):
                sec = "METARELEASE"
                for k in ["URI",
                          "URI_LTS",
                          "URI_UNSTABLE_POSTFIX",
                          "URI_PROPOSED_POSTFIX"]:
                    if parser.has_option(sec, k):
                        self._debug("%s: %s " % (self.CONF_METARELEASE,
                                                 parser.get(sec,k)))
                        setattr(self, "%s_%s" % (sec, k), parser.get(sec, k))

        # check the config file first to figure if we want lts upgrades only
        parser = ConfigParser()
        if os.path.exists(self.CONF):
            parser.read(self.CONF)
            # now check which specific url to use
            if parser.has_option("DEFAULT","Prompt"):
                type = parser.get("DEFAULT","Prompt").lower()
                if (type == "never" or type == "no"):
                    # nothing to do for this object
                    # FIXME: what about no longer supported?
                    self.downloading = False
                    return
                elif type == "lts":
                    self.METARELEASE_URI = self.METARELEASE_URI_LTS
        # needed for the _tryUpgradeSelf() code in DistUpgradeController
        if forceLTS:
            self.METARELEASE_URI = self.METARELEASE_URI_LTS
        # devel and proposed "just" change the postfix
        if useDevelopmentRelease:
            self.METARELEASE_URI += self.METARELEASE_URI_UNSTABLE_POSTFIX
        elif useProposed:
            self.METARELEASE_URI += self.METARELEASE_URI_PROPOSED_POSTFIX

        self._debug("metarelease-uri: %s" % self.METARELEASE_URI)
        self.metarelease_information = None
        if not self._buildMetaReleaseFile():
            self._debug("_buildMetaReleaseFile failed")
            return
        # we start the download thread here and we have a timeout
        t=thread.start_new_thread(self.download, ())
        #t=thread.start_new_thread(self.check, ())

    def _buildMetaReleaseFile(self):
        # build the metarelease_file name
        self.METARELEASE_FILE = os.path.join("/var/lib/update-manager/",
                                            os.path.basename(self.METARELEASE_URI))
        # check if we can write to the global location, if not,
        # write to homedir
        try:
            open(self.METARELEASE_FILE,"a")
        except IOError, e:
            path = os.path.expanduser("~/.update-manager-core/")
            if not os.path.exists(path):
		try:
                    os.mkdir(path)
		except OSError, e:
                    sys.stderr.write("mkdir() failed: '%s'" % e)
		    return False
            self.METARELEASE_FILE = os.path.join(path,os.path.basename(self.METARELEASE_URI))
        # if it is empty, remove it to avoid I-M-S hits on empty file
        try:
            if os.path.getsize(self.METARELEASE_FILE) == 0:
                os.unlink(self.METARELEASE_FILE)
        except Exception, e:
            pass
        return True

    def dist_no_longer_supported(self, dist):
        """ virtual function that is called when the distro is no longer
            supported
        """
        self.no_longer_supported = dist
    def new_dist_available(self, dist):
        """ virtual function that is called when a new distro release
            is available
        """
        self.new_dist = dist

    def parse(self):
        self._debug("MetaRelease.parse()")
        current_dist_name = self.current_dist_name
        self._debug("current dist name: '%s'" % current_dist_name)
        current_dist = None
        dists = []

        # parse the metarelease_information file
        index_tag = apt_pkg.ParseTagFile(self.metarelease_information)
        step_result = index_tag.Step()
        while step_result:
            if index_tag.Section.has_key("Dist"):
                name = index_tag.Section["Dist"]
                #print name
                rawdate = index_tag.Section["Date"]
                date = time.mktime(rfc822.parsedate(rawdate))
                supported = bool(index_tag.Section["Supported"])
                version = index_tag.Section["Version"]
                # add the information to a new date object
                dist = Dist(name, version, date,supported)
                if index_tag.Section.has_key("ReleaseNotes"):
                    dist.releaseNotesURI = index_tag.Section["ReleaseNotes"]
                if index_tag.Section.has_key("UpgradeTool"):
                    dist.upgradeTool =  index_tag.Section["UpgradeTool"]
                if index_tag.Section.has_key("UpgradeToolSignature"):
                    dist.upgradeToolSig =  index_tag.Section["UpgradeToolSignature"]
                dists.append(dist)
                if name == current_dist_name:
                    current_dist = dist 
            step_result = index_tag.Step()

        # first check if the current runing distro is in the meta-release
        # information. if not, we assume that we run on something not
        # supported and silently return
        if current_dist is None:
            #sys.stderr.write("current dist not found in meta-release file\n")
            return False

        # then see what we can upgrade to (only upgrade to supported dists)
        upgradable_to = ""
        for dist in dists:
            if dist.date > current_dist.date and dist.supported == True: 
                upgradable_to = dist
                self._debug("new dist: %s" % upgradable_to)
                break

        # only warn if unsupported and a new dist is available (because 
        # the development version is also unsupported)
        if upgradable_to != "" and not current_dist.supported:
            self.dist_no_longer_supported(upgradable_to)
        elif upgradable_to != "":
            self.new_dist_available(upgradable_to)

        # parsing done and sucessfully
        return True

    # the network thread that tries to fetch the meta-index file
    # can't touch the gui, runs as a thread
    def download(self):
        self._debug("MetaRelease.download()")
        lastmodified = 0
        req = urllib2.Request(self.METARELEASE_URI)
        # make sure that we always get the latest file (#107716)
        req.add_header("Cache-Control", "No-Cache")
        req.add_header("Pragma", "no-cache")
        if os.access(self.METARELEASE_FILE, os.W_OK):
            lastmodified = os.stat(self.METARELEASE_FILE).st_mtime
        if lastmodified > 0:
            req.add_header("If-Modified-Since", time.asctime(time.gmtime(lastmodified)))
        try:
            uri=urllib2.urlopen(req)
            # sometime there is a root owned meta-relase file
            # there, try to remove it so that we get it
            # with proper permissions
            if (os.path.exists(self.METARELEASE_FILE) and
                not os.access(self.METARELEASE_FILE,os.W_OK)):
                try:
                    os.unlink(self.METARELEASE_FILE)
                except OSError,e:
                    print "Can't unlink '%s' (%s)" % (self.METARELEASE_FILE,e)
            # we may get excpetion here on e.g. disk full
            try:
                f=open(self.METARELEASE_FILE,"w+")
                for line in uri.readlines():
                    f.write(line)
                f.flush()
                f.seek(0,0)
                self.metarelease_information=f
            except IOError, e:
                pass
            uri.close()
        except (urllib2.URLError, httplib.BadStatusLine), e:
            if os.path.exists(self.METARELEASE_FILE):
                self.metarelease_information=open(self.METARELEASE_FILE,"r")
        # now check the information we have
        if self.metarelease_information != None:
            self._debug("have self.metarelease_information")
            self.parse()
        else:
            self._debug("NO self.metarelease_information")
        self.downloading = False

    def _debug(self, msg):
        if self.DEBUG:
            sys.stderr.write(msg+"\n")


if __name__ == "__main__":
    meta = MetaReleaseCore(False, False)
    
