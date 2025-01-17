# MyCache.py 
#  
#  Copyright (c) 2004-2008 Canonical
#  
#  Author: Michael Vogt <mvo@debian.org>
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

import warnings
warnings.filterwarnings("ignore", "apt API not stable yet", FutureWarning)
import apt
import apt_pkg
import os
import string
import urllib2
import httplib
import socket
import re
import DistUpgrade.DistUpgradeCache
from DistUpgrade.DistUpgradeCache import NotEnoughFreeSpaceError
from gettext import gettext as _
from UpdateList import UpdateOrigin

SYNAPTIC_PINFILE = "/var/lib/synaptic/preferences"
CHANGELOGS_URI="http://changelogs.ubuntu.com/changelogs/pool/%s/%s/%s/%s_%s/%s"
CHANGELOG_ORIGIN = "Ubuntu"

class MyCache(DistUpgrade.DistUpgradeCache.MyCache):
    def __init__(self, progress, rootdir=None):
        apt.Cache.__init__(self, progress, rootdir)
        # raise if we have packages in reqreinst state
        # and let the caller deal with that (runs partial upgrade)
        assert len(self.reqReinstallPkgs) == 0
        # check if the dpkg journal is ok (we need to do that here
        # too because libapt will only do it when it tries to lock
        # the packaging system)
        assert(not self._dpkgJournalDirty())
        # init the regular cache
        self._initDepCache()
        self.all_changes = {}
        self.all_news = {}
        # on broken packages, try to fix via saveDistUpgrade()
        if self._depcache.BrokenCount > 0:
            self.saveDistUpgrade()
        assert (self._depcache.BrokenCount == 0 and 
                self._depcache.DelCount == 0)

    def _dpkgJournalDirty(self):
        """
        test if the dpkg journal is dirty
        (similar to debSystem::CheckUpdates)
        """
        d = os.path.dirname(
            apt_pkg.Config.FindFile("Dir::State::status"))+"/updates"
        for f in os.listdir(d):
            if re.match("[0-9]+", f):
                return True
        return False

    def _initDepCache(self):
        #apt_pkg.Config.Set("Debug::pkgPolicy","1")
        #self.depcache = apt_pkg.GetDepCache(self.cache)
        #self._depcache = apt_pkg.GetDepCache(self._cache)
        self._depcache.ReadPinFile()
        if os.path.exists(SYNAPTIC_PINFILE):
            self._depcache.ReadPinFile(SYNAPTIC_PINFILE)
        self._depcache.Init()
    def clear(self):
        self._initDepCache()
    @property
    def requiredDownload(self):
        """ get the size of the packages that are required to download """
        pm = apt_pkg.GetPackageManager(self._depcache)
        fetcher = apt_pkg.GetAcquire()
        pm.GetArchives(fetcher, self._list, self._records)
        return fetcher.FetchNeeded
    @property
    def installCount(self):
        return self._depcache.InstCount
    def saveDistUpgrade(self):
        """ this functions mimics a upgrade but will never remove anything """
        self._depcache.Upgrade(True)
        wouldDelete = self._depcache.DelCount
        if self._depcache.DelCount > 0:
            self.clear()
        assert self._depcache.BrokenCount == 0 and self._depcache.DelCount == 0
        self._depcache.Upgrade()
        return wouldDelete
    def matchPackageOrigin(self, pkg, matcher):
        """ match 'pkg' origin against 'matcher', take versions between
            installedVersion and candidateVersion into account too
            Useful if installed pkg A v1.0 is available in both
            -updates (as v1.2) and -security (v1.1). we want to display
            it as a security update then
        """
        inst_ver = pkg._pkg.CurrentVer
        cand_ver = self._depcache.GetCandidateVer(pkg._pkg)
        # init matcher with candidateVer
        update_origin = matcher[(None,None)]
        verFileIter = None
        for (verFileIter,index) in cand_ver.FileList:
            if matcher.has_key((verFileIter.Archive, verFileIter.Origin)):
                indexfile = pkg._pcache._list.FindIndex(verFileIter)
                if indexfile: # and indexfile.IsTrusted:
                    match = matcher[verFileIter.Archive, verFileIter.Origin]
                    update_origin = match
                    break
        else:
            # add a node for each origin/archive combination
            if verFileIter and verFileIter.Origin and verFileIter.Archive:
                matcher[verFileIter.Archive, verFileIter.Origin] = UpdateOrigin(_("Other updates (%s)") % verFileIter.Origin, 0)
                update_origin = matcher[verFileIter.Archive, verFileIter.Origin]
        # if the candidate comes from a unknown source (e.g. a PPA) skip
        # skip the shadow logic below as it would put e.g. a PPA package
        # in "Recommended updates" when the version in the PPA 
        # is higher than the one in %s-updates
        if update_origin.importance <= 0:
            return update_origin
        # for known packages, check if we have higher versions that
        # "shadow" this one
        for ver in pkg._pkg.VersionList:
            # discard is < than installed ver
            if (inst_ver and
                apt_pkg.VersionCompare(ver.VerStr, inst_ver.VerStr) <= 0):
                #print "skipping '%s' " % ver.VerStr
                continue
            # check if we have a match
            for(verFileIter,index) in ver.FileList:
                if matcher.has_key((verFileIter.Archive, verFileIter.Origin)):
                    indexfile = pkg._pcache._list.FindIndex(verFileIter)
                    if indexfile: # and indexfile.IsTrusted:
                        match = matcher[verFileIter.Archive, verFileIter.Origin]
                        if match.importance > update_origin.importance:
                            update_origin = match
        return update_origin

    def _strip_epoch(self, verstr):
        " strip of the epoch "
        l = string.split(verstr,":")
        if len(l) > 1:
            verstr = "".join(l[1:])
        return verstr
        
    def _get_changelog_or_news(self, name, fname, strict_versioning=False, changelogs_uri=None):
        " helper that fetches the file in question "
        # don't touch the gui in this function, it needs to be thread-safe
        pkg = self[name]

        # get the src package name
        srcpkg = pkg.sourcePackageName

        # assume "main" section 
        src_section = "main"
        # use the section of the candidate as a starting point
        section = pkg._pcache._depcache.GetCandidateVer(pkg._pkg).Section

        # get the source version, start with the binaries version
        binver = pkg.candidateVersion
        srcver_epoch = pkg.candidateVersion
        srcver = self._strip_epoch(srcver_epoch)
        #print "bin: %s" % binver

        l = section.split("/")
        if len(l) > 1:
            src_section = l[0]

        # lib is handled special
        prefix = srcpkg[0]
        if srcpkg.startswith("lib"):
            prefix = "lib" + srcpkg[3]

        uri = (changelogs_uri or CHANGELOGS_URI) % (src_section,prefix,srcpkg,srcpkg, srcver, fname)
        # print "Trying: %s " % uri
        changelog = urllib2.urlopen(uri)
        #print changelog.read()
        # do only get the lines that are new
        alllines = ""
        regexp = "^%s \((.*)\)(.*)$" % (re.escape(srcpkg))
        
        i=0
        while True:
            line = changelog.readline()
            if line == "":
                break
            match = re.match(regexp,line)
            if match:
                # strip epoch from installed version
                # and from changelog too
                installed = pkg.installedVersion
                if installed and ":" in installed:
                    installed = installed.split(":",1)[1]
                changelogver = match.group(1)
                if changelogver and ":" in changelogver:
                    changelogver = changelogver.split(":",1)[1]
                # we test for "==" here for changelogs 
                # to ensure that the version
                # is actually really in the changelog - if not
                # just display it all, this catches cases like:
                # gcc-defaults with "binver=4.3.1" and srcver=1.76
                # 
                # for NEWS.Debian we do require the changelogver > installed
                if strict_versioning:
                    if (installed and 
                        apt_pkg.VersionCompare(changelogver,installed)<0):
                        break
                else:
                    if (installed and 
                        apt_pkg.VersionCompare(changelogver,installed)==0):
                        break
            alllines = alllines + line
        return alllines

    def _guess_third_party_changelogs_uri(self, name):
        """ guess changelogs uri based on ArchiveURI by just appending
            /changelogs/pool/section/prefix/pkg/version/pkgname
        """
        pkg = self[name]
        cand = pkg._pcache._depcache.GetCandidateVer(pkg._pkg)
        if cand and cand.FileList:
            for (packagefile, i) in cand.FileList:
                indexfile = self._list.FindIndex(packagefile)
                if indexfile:
                    base_uri = indexfile.ArchiveURI("")
                    return base_uri+"/changelogs/pool/%s/%s/%s/%s_%s/%s"
        return None

        
    def get_news_and_changelog(self, name, lock):
        self.get_news(name)
        self.get_changelog(name)
        try:
            lock.release()        
        except:
            pass
    
    def get_news(self, name):
        " get the NEWS.Debian file from the changelogs location "
        try:
            news = self._get_changelog_or_news(name, "NEWS.Debian", True)
        except Exception, e:
            return
        if news:
            self.all_news[name] = news
                    
    def get_changelog(self, name):
        " get the changelog file from the changelog location "
        origins = self[name].candidateOrigin
        self.all_changes[name] = _("Changes for the versions:\n%s\n%s\n\n") % (self[name].installedVersion, self[name].candidateVersion)
        if not CHANGELOG_ORIGIN in [o.origin for o in origins]:
            # Try non official changelog location
            changelogs_uri = self._guess_third_party_changelogs_uri(name)
            if changelogs_uri:
                try:
                    changelog = self._get_changelog_or_news(name, "changelog", False, changelogs_uri)
                    self.all_changes[name] += changelog
                    return
                except urllib2.HTTPError, e:
                    pass
            # no changelogs_uri or 404
            self.all_changes[name] += _( "This change is not coming from a "
                                         "source that supports changelogs.")
            return
        # fixup epoch handling version
        srcpkg = self[name].sourcePackageName
        srcver_epoch = self[name].candidateVersion.replace(':', '%3A')
        try:
            changelog = self._get_changelog_or_news(name, "changelog")
            if len(changelog) == 0:
                changelog = _("The changelog does not contain any relevant changes.\n\n"
                              "Please use http://launchpad.net/ubuntu/+source/%s/%s/+changelog\n"
                              "until the changes become available or try again "
                              "later.") % (srcpkg, srcver_epoch)
        except urllib2.HTTPError, e:
            changelog = _("The list of changes is not available yet.\n\n"
                          "Please use http://launchpad.net/ubuntu/+source/%s/%s/+changelog\n"
                          "until the changes become available or try again "
                          "later.") % (srcpkg, srcver_epoch)
        except (IOError, httplib.BadStatusLine, socket.error), e:
            print "caught exception: ", e
            changelog = _("Failed to download the list "
                          "of changes. \nPlease "
                          "check your Internet "
                          "connection.")
        self.all_changes[name] += changelog



