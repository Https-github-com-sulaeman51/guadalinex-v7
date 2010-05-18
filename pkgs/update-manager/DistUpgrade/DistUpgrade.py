#!/usr/bin/python2.4

import pygtk
pygtk.require('2.0')
import gtk
import gtk.gdk
import gtk.glade
import vte
import gobject

import apt
import apt_pkg
import sys
import os
import subprocess

from UpdateManager.Common.SimpleGladeApp import SimpleGladeApp
from UpdateManager.GtkProgress import GtkOpProgress
from SoftwareProperties.aptsources import SourcesList, SourceEntry
from gettext import gettext as _
from apt.progress import InstallProgress


class MyCache(apt.Cache):
    @property
    def requiredDownload(self):
        pm = apt_pkg.GetPackageManager(self._depcache)
        fetcher = apt_pkg.GetAcquire()
        pm.GetArchives(fetcher, self._list, self._records)
        return fetcher.FetchNeeded
    def downloadable(self, pkg, useCandidate=True):
        " check if the given pkg can be downloaded "
        if useCandidate:
            ver = self._depcache.GetCandidateVer(pkg._pkg)
        else:
            ver = pkg._pkg.CurrentVer
        if ver == None:
            return False
        return ver.Downloadable

class DistUpgradeView(object):
    " abstraction for the upgrade view "
    def __init__(self):
        pass
    def getOpCacheProgress(self):
        " return a OpProgress() subclass for the given graphic"
        return apt.progress.OpProgress()
    def getFetchProgress(self):
        " return a fetch progress object "
        return apt.progress.FetchProgress()
    def getInstallProgress(self):
        " return a install progress object "
        return apt.progress.InstallProgress()
    def updateStatus(self, msg):
        """ update the current status of the distUpgrade based
            on the current view
        """
        pass
    def confirmChanges(self, changes, downloadSize):
        """ display the list of changed packages (apt.Package) and
            return if the user confirms them
        """
        self.toInstall = []
        self.toUpgrade = []
        self.toRemove = []
        for pkg in changes:
            if pkg.markedInstall: self.toInstall.append(pkg.name)
            elif pkg.markedUpgrade: self.toUpgrade.append(pkg.name)
            elif pkg.markedDelete: self.toRemove.append(pkg.name)
        # no downgrades, re-installs 
        assert(len(self.toInstall)+len(self.toUpgrade)+len(self.toRemove) == len(changes))
    def askYesNoQuestion(self, summary, msg):
        pass
    def error(self, summary, msg):
        pass
        

class GtkDistUpgradeView(DistUpgradeView,SimpleGladeApp):
    " gtk frontend of the distUpgrade tool "

    class GtkFetchProgressAdapter(apt.progress.FetchProgress):
        # FIXME: we really should have some sort of "we are at step"
        # xy in the gui
        # FIXME2: we need to thing about mediaCheck here too
        def __init__(self, parent):
            # if this is set to false the download will cancel
            self.status = parent.label_extra_status
            self.progress = parent.progressbar_cache
        def start(self):
            self.progress.show()
            self.progress.set_fraction(0)
            self.status.show()
        def stop(self):
            self.progress.hide()
            self.status.hide()
            self.status.hide()
        def pulse(self):
            # FIXME: move the status_str and progress_str into python-apt
            # (python-apt need i18n first for this)
            apt.progress.FetchProgress.pulse(self)
            if self.currentCPS > 0:
                self.status.set_text(_("Download rate: %s/s - %s remaining" % (apt_pkg.SizeToStr(self.currentCPS), apt_pkg.TimeToStr(self.eta))))
            else:
                self.status.set_text(_("Download rate: unkown"))
            self.progress.set_fraction(self.percent/100.0)
            currentItem = self.currentItems + 1
            if currentItem > self.totalItems:
                currentItem = self.totalItems
            self.progress.set_text(_("Downloading file %li of %li" % (currentItem, self.totalItems)))
            while gtk.events_pending():
                gtk.main_iteration()
            return True

    class GtkInstallProgressAdapter(InstallProgress):
        def __init__(self,parent):
            InstallProgress.__init__(self)
            self.label_status = parent.label_extra_status
            self.progress = parent.progressbar_cache
            self.expander = parent.expander_terminal
            self.term = parent._term
            # setup the child waiting
            reaper = vte.reaper_get()
            reaper.connect("child-exited", self.child_exited)
            self.finished = False
        def startUpdate(self):
            self.label_status.show()
            self.label_status.set_text(_("Installing updates ..."))
            self.progress.show()
            self.progress.set_fraction(0.0)
            self.progress.set_text("")
            self.expander.show()
            self.term.show()
            # FIXME: set the environment up for DEBCONF and APT_LISTCHANGES
            # to default to gtk frontends, also add support for the timeout
            # of the terminal (to display something useful then)
            # -> longer term, move this code into python-apt 
            self.env = ["VTE_PTY_KEEP_FD=%s"% self.writefd,
                        "DEBIAN_FRONTEND=gnome",
                        "APT_LISTCHANGES_FRONTEND=gtk"]
        def fork(self):
            return self.term.forkpty(envv=self.env)
        def child_exited(self, term, pid, status):
            self.apt_status = os.WEXITSTATUS(status)
            self.finished = True
        def waitChild(self):
            while not self.finished:
                self.updateInterface()
            return self.apt_status
        def finishUpdate(self):
            self.progress.hide()
            self.label_status.hide()
        def updateInterface(self):
            InstallProgress.updateInterface(self)
            self.progress.set_fraction(self.percent/100.0)
            self.label_status.set_text(self.status)
            while gtk.events_pending():
                gtk.main_iteration()
      
    
    def __init__(self):
        # FIXME: i18n must be somewhere relative do this dir
        SimpleGladeApp.__init__(self, "DistUpgrade.glade",
                                None, domain="update-manager")
        self._opCacheProgress = GtkOpProgress(self.progressbar_cache)
        self._fetchProgress = self.GtkFetchProgressAdapter(self)
        self._installProgress = self.GtkInstallProgressAdapter(self)
        # details dialog
        self.details_list = gtk.ListStore(gobject.TYPE_STRING)
        column = gtk.TreeViewColumn("")
        render = gtk.CellRendererText()
        column.pack_start(render, True)
        column.add_attribute(render, "markup", 0)
        self.treeview_details.append_column(column)
        self.treeview_details.set_model(self.details_list)

    def create_terminal(self, arg1,arg2,arg3,arg4):
        " helper to create a vte terminal "
        print "create_vte (for the custom glade widget)"
        self._term = vte.Terminal()
        self._term.set_font_from_string("monospace 10")
        return self._term
    def getFetchProgress(self):
        return self._fetchProgress
    def getInstallProgress(self):
        return self._installProgress
    def getOpCacheProgress(self):
        return self._opCacheProgress
    def updateStatus(self, msg):
        self.label_status.set_markup("%s" % msg)
    def error(self, summary, msg):
        dialog = gtk.MessageDialog(self.window_main, 0, gtk.MESSAGE_ERROR,
                                   gtk.BUTTONS_OK,"")
        msg="<big><b>%s</b></big>\n\n%s" % (summary,msg)
        dialog.set_markup(msg)
        dialog.vbox.set_spacing(6)
        dialog.run()
        dialog.destroy()
        return False
    def confirmChanges(self, changes, downloadSize):
        # FIXME: add a whitelist here for packages that we expect to be
        # removed (how to calc this automatically?)
        DistUpgradeView.confirmChanges(self, changes,downloadSize)
        msg = _("%s packages are going to be removed.\n"
                "%s packages are going to be newly installed.\n"
                "%s packages are going to be upgraded.\n\n"
                "%s needs to be fetched" % (len(self.toRemove),
                                            len(self.toInstall),
                                            len(self.toUpgrade),
                                            apt_pkg.SizeToStr(downloadSize)))
        self.label_changes.set_text(msg)
        # fill in the details
        self.details_list.clear()
        for rm in self.toRemove:
            self.details_list.append([_("<b>To be removed: %s</b>" % rm)])
        for inst in self.toInstall:
            self.details_list.append([_("To be installed: %s" % inst)])
        for up in self.toUpgrade:
            self.details_list.append([_("To be upgraded: %s" % up)])
        res = self.dialog_changes.run()
        self.dialog_changes.hide()
        if res == gtk.RESPONSE_YES:
            return True
        return False
    def askYesNoQuestion(self, summary, msg):
        msg = "<big><b>%s</b></big>\n\n%s" % (summary,msg)
        dialog = gtk.MessageDialog(parent=self.window_main,
                                   flags=gtk.DIALOG_MODAL,
                                   type=gtk.MESSAGE_QUESTION,
                                   buttons=gtk.BUTTONS_YES_NO)
        dialog.set_markup(msg)
        res = dialog.run()
        dialog.destroy()
        if res == gtk.RESPONSE_YES:
            return True
        return False

        
class DistUpgradeControler(object):
    def __init__(self, distUpgradeView):
        self._view = distUpgradeView
        self._view.updateStatus(_("Reading cache"))
        self._cache = MyCache(self._view.getOpCacheProgress())
        # some constants here
        self.fromDist = "hoary"
        self.toDist = "breezy"
        self.origin = "Ubuntu"

    def sanityCheck(self):
        if self._cache._depcache.BrokenCount > 0:
            # FIXME: we more helpful here and offer to actually fix the
            # system
            self._view.error(_("Broken packages"),
                             _("Your system contains broken packages. "
                               "Please fix them first using synaptic or "
                               "apt-get before proceeding."))
            return False
        # FIXME: check for ubuntu-desktop, kubuntu-dekstop, edubuntu-desktop
        return True

    def updateSourcesList(self):
        sources = SourcesList()

        # this must map, i.e. second in "from" must be the second in "to"
        # (but they can be different, so in theory we could exchange
        #  component names here)
        fromDists = [self.fromDist,
                     self.fromDist+"-security",
                     self.fromDist+"-updates",
                     self.fromDist+"-backports"
                    ]
        toDists = [self.toDist,
                   self.toDist+"-security",
                   self.toDist+"-updates",
                   self.toDist+"-backports"
                   ]

        # list of valid mirrors that we can add
        valid_mirrors = ["http://archive.ubuntu.com/ubuntu",
                         "http://security.ubuntu.com/ubuntu"]

        # look over the stuff we have
        foundToDist = False
        for entry in sources:
            # check if it's a mirror (or offical site)
            for mirror in valid_mirrors:
                if sources.is_mirror(mirror,entry.uri):
                    if entry.dist in toDists:
                        # so the sources.list is already set to the new
                        # distro
                        foundToDist = True
                    elif entry.dist in fromDists:
                        foundToDist = True
                        entry.dist = toDists[fromDists.index(entry.dist)]
                    else:
                        # disable all entries that are official but don't
                        # point to the "from" dist
                        entry.disabled = True
                    # it can only be one valid mirror, so we can break here
                    break
                else:
                    # disable non-official entries that point to dist
                    if entry.dist == self.fromDist:
                        entry.disabled = True

        if not foundToDist:
            # FIXME: offer to write a new sources.list entry
            return self._view.error(_("No valid entry found"),
                                    _("While scaning your repository "
                                      "information no valid entry for "
                                      "the upgrade was found.\n"))
        
        # write (well, backup first ;) !
        backup_ext = ".distUpgrade"
        sources.backup(backup_ext)
        sources.save()

        # re-check if the written sources are valid, if not revert and
        # bail out
        try:
            sourceslist = apt_pkg.GetPkgSourceList()
            sourceslist.ReadMainList()
        except SystemError:
            sources.restoreBackup(backup_ext)
            self._view.error(_("Repository information invalid"),
                             _("Upgrading the repository information "
                               "resulted in a invalid file. Please "
                               "report this as a bug."))
            return False
        return True

    def _getObsoletesPkgs(self):
        " get all package names that are not downloadable "
        obsolete_pkgs =set()        
        for pkg in self._cache:
            if pkg.isInstalled:
                if not self._cache.downloadable(pkg):
                    obsolete_pkgs.add(pkg.name)
        return obsolete_pkgs

    def _getForeignPkgs(self):
        """ get all packages that are installed from a foreign repo
            (and are actually downloadable)
        """
        foreign_pkgs =set()        
        for pkg in self._cache:
            if pkg.isInstalled and self._cache.downloadable(pkg):
                # assume it is foreign and see if it is from the 
                # official archive
                foreign=True
                for origin in pkg.candidateOrigin:
                    if self.fromDist in origin.archive and \
                           origin.origin == self.origin:
                        foreign = False
                    if self.toDist in origin.archive and \
                           origin.origin == self.origin:
                        foreign = False
                if foreign:
                    foreign_pkgs.add(pkg.name)
        return foreign_pkgs

    def doPreUpgrade(self):
        # FIXME: check out what packages are downloadable etc to
        # compare the list after the update again
        self.obsolete_pkgs = self._getObsoletesPkgs()
        self.foreign_pkgs = self._getForeignPkgs()
        #print self.foreign_pkgs
        #print self.obsolete_pkgs

    def doUpdate(self):
        self._cache._list.ReadMainList()
        progress = self._view.getFetchProgress()
        self._cache.update(progress)

    def askDistUpgrade(self):
        # FIXME: add "ubuntu-desktop" (or kubuntu-desktop, edubuntu-desktop)
        #        (if required)
        self._cache.upgrade(True)
        changes = self._cache.getChanges()
        res = self._view.confirmChanges(changes,self._cache.requiredDownload)
        return res

    def doDistUpgrade(self):
        fprogress = self._view.getFetchProgress()
        iprogress = self._view.getInstallProgress()
        self._cache.commit(fprogress,iprogress)

    def doPostUpgrade(self):
        # FIXME: check out what packages are cruft now
        # use self.{foreign,obsolete}_pkgs here and see what changed
        pass

    def askForReboot(self):
        return self._view.askYesNoQuestion(_("Reboot required"),
                                           _("The upgrade is finished now. "
                                             "A reboot is required to "
                                             "now, do you want to do this "
                                             "now?"))
    
    # this is the core
    def breezyUpgrade(self):
        # sanity check (check for ubuntu-desktop, brokenCache etc)
        self._view.updateStatus(_("Checking the system"))
        if not self.sanityCheck():
            sys.exit(1)

        # do pre-upgrade stuff (calc list of obsolete pkgs etc)
        self.doPreUpgrade()

        # update sources.list
        self._view.updateStatus(_("Updating repository information"))
        if not self.updateSourcesList():
            sys.exit(1)
        # then update the package index files
        self.doUpdate()

        # then open the cache (again)
        self._view.updateStatus(_("Reading cache"))
        self._cache = MyCache(self._view.getOpCacheProgress())

        # calc the dist-upgrade and see if the removals are ok/expected
        # do the dist-upgrade
        self._view.updateStatus(_("Performing the upgrade"))
        if not self.askDistUpgrade():
            sys.exit(1)
        self.doDistUpgrade()
            
        # do post-upgrade stuff
        self.doPostUpgrade()

        # done, ask for reboot
        if self.askForReboot():
            subprocess.call(["reboot"])
        
    def run(self):
        self.breezyUpgrade()


if __name__ == "__main__":
    view = GtkDistUpgradeView()
    app = DistUpgradeControler(view)
    app.run()
