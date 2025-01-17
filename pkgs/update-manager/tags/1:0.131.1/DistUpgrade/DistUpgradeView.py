# DistUpgradeView.py 
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

from DistUpgradeGettext import gettext as _
from DistUpgradeGettext import ngettext
import subprocess
from subprocess import Popen, PIPE
import apt
import os
import apt_pkg 
import signal
import glob
import select

from DistUpgradeAufs import doAufsChroot, doAufsChrootRsync
from DistUpgradeApport import *


def FuzzyTimeToStr(sec):
  " return the time a bit fuzzy (no seconds if time > 60 secs "
  #print "FuzzyTimeToStr: ", sec
  sec = int(sec)

  days = sec/(60*60*24)
  hours = sec/(60*60) % 24
  minutes = (sec/60) % 60
  seconds = sec % 60
  # 0 seonds remaining looks wrong and its "fuzzy" anyway
  if seconds == 0:
    seconds = 1

  # string map to make the re-ordering possible
  map = { "str_days" : "",
          "str_hours" : "",
          "str_minutes" : "",
          "str_seconds" : ""
        }
  
  # get the fragments, this is not ideal i18n wise, but its
  # difficult to do it differently
  if days > 0:
    map["str_days"] = ngettext("%li day","%li days", days) % days
  if hours > 0:
    map["str_hours"] = ngettext("%li hour","%li hours", hours) % hours
  if minutes > 0:
    map["str_minutes"] = ngettext("%li minute","%li minutes", minutes) % minutes
  map["str_seconds"] = ngettext("%li second","%li seconds", seconds) % seconds

  # now assemble the string
  if days > 0:
    # TRANSLATORS: you can alter the ordering of the remaining time
    # information here if you shuffle %(str_days)s %(str_hours)s %(str_minutes)s
    # around. Make sure to keep all '$(str_*)s' in the translated string
    # and do NOT change anything appart from the ordering.
    #
    # %(str_hours)s will be either "1 hour" or "2 hours" depending on the
    # plural form
    # 
    # Note: most western languages will not need to change this
    return _("%(str_days)s %(str_hours)s") % map
  # display no minutes for time > 3h, see LP: #144455
  elif hours > 3:
    return map["str_hours"]
  # when we are near the end, become more precise again
  elif hours > 0:
    # TRANSLATORS: you can alter the ordering of the remaining time
    # information here if you shuffle %(str_hours)s %(str_minutes)s
    # around. Make sure to keep all '$(str_*)s' in the translated string
    # and do NOT change anything appart from the ordering.
    #
    # %(str_hours)s will be either "1 hour" or "2 hours" depending on the
    # plural form
    # 
    # Note: most western languages will not need to change this
    return _("%(str_hours)s %(str_minutes)s") % map
  elif minutes > 0:
    return map["str_minutes"]
  return map["str_seconds"]


class FetchProgress(apt.progress.FetchProgress):
  def __init__(self):
    #print "init FetchProgress in DistUpgradeView"
    apt.progress.FetchProgress.__init__(self)
    self.est_speed = 0
  def start(self):
    self.release_file_download_error = False
  def updateStatus(self, uri, descr, shortDescr, status):
    # FIXME: workaround issue in libapt/python-apt that does not 
    #        raise a exception if *all* files fails to download
    if status == self.dlFailed:
      logging.warn("updateStatus: dlFailed on '%s' " % uri)
      if uri.endswith("Release.gpg") or uri.endswith("Release"):
        # only care about failures from network, not gpg, bzip, those
        # are different issues
        for net in ["http","ftp","mirror"]:
          if uri.startswith(net):
            self.release_file_download_error = True
            break
  def pulse(self):
    apt.progress.FetchProgress.pulse(self)
    if self.currentCPS > self.est_speed:
      self.est_speed = (self.est_speed+self.currentCPS)/2.0
    return True
  def estimatedDownloadTime(self, requiredDownload):
    """ get the estimated download time """
    if self.est_speed == 0:
      timeModem = requiredDownload/(56*1024/8)  # 56 kbit 
      timeDSL = requiredDownload/(1024*1024/8)  # 1Mbit = 1024 kbit
      s= _("This download will take about %s with a 1Mbit DSL connection "
           "and about %s with a 56k modem.") % (FuzzyTimeToStr(timeDSL), FuzzyTimeToStr(timeModem))
      return s
    # if we have a estimated speed, use it
    s = _("This download will take about %s with your connection. ") % FuzzyTimeToStr(requiredDownload/self.est_speed)
    return s
    


class InstallProgress(apt.progress.InstallProgress):
  """ Base class for InstallProgress that supports some fancy
      stuff like apport integration
  """
  def __init__(self):
    apt.progress.InstallProgress.__init__(self)
    self.master_fd = None

  def waitChild(self):
      """Wait for child progress to exit.

      The return values is the full status returned from os.waitpid()
      (not only the return code).
      """
      while True:
          try:
              select.select([self.statusfd], [], [], self.selectTimeout)
          except select.error, (errno_, errstr):
              if errno_ != errno.EINTR:
                  raise
          self.updateInterface()
          try:
              (pid, res) = os.waitpid(self.child_pid, os.WNOHANG)
              if pid == self.child_pid:
                  break
          except OSError, (errno_, errstr):
              if errno_ != errno.EINTR:
                  raise
              if errno_ == errno.ECHILD:
                  break
      return res

  def run(self, pm):
    pid = self.fork()
    if pid == 0:
      # check if we need to setup/enable the aufs chroot stuff
      if "RELEASE_UPGRADE_USE_AUFS_CHROOT" in os.environ:
        if not doAufsChroot(os.environ["RELEASE_UPGRADE_AUFS_RWDIR"],
                            os.environ["RELEASE_UPGRADE_USE_AUFS_CHROOT"]):
          print "ERROR: failed to setup aufs chroot overlay"
          os._exit(1)
      # child, ignore sigpipe, there are broken scripts out there
      # like etckeeper (LP: #283642)
      signal.signal(signal.SIGPIPE,signal.SIG_IGN) 
      try:
        res = pm.DoInstall(self.writefd)
      except Exception, e:
        print "Exception during pm.DoInstall(): ", e
        logging.exception("Exception during pm.DoInstall()")
        os._exit(pm.ResultFailed)
      os._exit(res)
    self.child_pid = pid
    res = os.WEXITSTATUS(self.waitChild())
    # check if we want to sync the changes back, *only* do that
    # if res is positive
    if (res == 0 and
        "RELEASE_UPGRADE_RSYNC_AUFS_CHROOT" in os.environ):
      logging.info("doing rsync commit of the update")
      if not doAufsChrootRsync(os.environ["RELEASE_UPGRADE_USE_AUFS_CHROOT"]):
        logging.error("FATAL ERROR: doAufsChrootRsync() returned FALSE")
        return pm.ResultFailed
    return res
  
  def error(self, pkg, errormsg):
    " install error from a package "
    apt.progress.InstallProgress.error(self, pkg, errormsg)
    logging.error("got an error from dpkg for pkg: '%s': '%s'" % (pkg, errormsg))
    if "/" in pkg:
      pkg = os.path.basename(pkg)
    if "_" in pkg:
      pkg = pkg.split("_")[0]
    # now run apport
    apport_pkgfailure(pkg, errormsg)

class DumbTerminal(object):
    def call(self, cmd, hidden=False):
        " expects a command in the subprocess style (as a list) "
        import subprocess
        subprocess.call(cmd)


(STEP_PREPARE,
 STEP_MODIFY_SOURCES,
 STEP_FETCH,
 STEP_INSTALL,
 STEP_CLEANUP,
 STEP_REBOOT,
 STEP_N) = range(1,8)

( _("Preparing to upgrade"),
  _("Getting new software channels"),
  _("Getting new packages"),
  _("Installing the upgrades"),
  _("Cleaning up"),
)

class DistUpgradeView(object):
    " abstraction for the upgrade view "
    def __init__(self):
        pass
    def getOpCacheProgress(self):
        " return a OpProgress() subclass for the given graphic"
        return apt.progress.OpProgress()
    def getFetchProgress(self):
        " return a fetch progress object "
        return FetchProgress()
    def getInstallProgress(self, cache=None):
        " return a install progress object "
        return InstallProgress()
    def getTerminal(self):
        return DumbTerminal()
    def updateStatus(self, msg):
        """ update the current status of the distUpgrade based
            on the current view
        """
        pass
    def abort(self):
        """ provide a visual feedback that the upgrade was aborted """
        pass
    def setStep(self, step):
        """ we have 6 steps current for a upgrade:
        1. Analyzing the system
        2. Updating repository information
        3. fetch packages
        3. Performing the upgrade
        4. Post upgrade stuff
        5. Complete
        """
        pass
    def hideStep(self, step):
        " hide a certain step from the GUI "
        pass
    def showStep(self, step):
        " show a certain step from the GUI "
        pass
    def confirmChanges(self, summary, changes, downloadSize,
                       actions=None, removal_bold=True):
        """ display the list of changed packages (apt.Package) and
            return if the user confirms them
        """
        self.confirmChangesMessage = ""
        self.toInstall = []
        self.toUpgrade = []
        self.toRemove = []
        self.toDowngrade = []
        for pkg in changes:
            if pkg.markedInstall: self.toInstall.append(pkg.name)
            elif pkg.markedUpgrade: self.toUpgrade.append(pkg.name)
            elif pkg.markedDelete: self.toRemove.append(pkg.name)
            elif pkg.markedDowngrade: self.toDowngrade.append(pkg.name)
        # sort it
        self.toInstall.sort()
        self.toUpgrade.sort()
        self.toRemove.sort()
        self.toDowngrade.sort()
        # no re-installs 
        assert(len(self.toInstall)+len(self.toUpgrade)+len(self.toRemove)+len(self.toDowngrade) == len(changes))
        # now build the message (the same for all frontends)
        msg = "\n"
        pkgs_remove = len(self.toRemove)
        pkgs_inst = len(self.toInstall)
        pkgs_upgrade = len(self.toUpgrade)
        # FIXME: show detailed packages
        if pkgs_remove > 0:
          # FIXME: make those two separate lines to make it clear
          #        that the "%" applies to the result of ngettext
          msg += ngettext("%d package is going to be removed.",
                          "%d packages are going to be removed.",
                          pkgs_remove) % pkgs_remove
          msg += " "
        if pkgs_inst > 0:
          msg += ngettext("%d new package is going to be "
                          "installed.",
                          "%d new packages are going to be "
                          "installed.",pkgs_inst) % pkgs_inst
          msg += " "
        if pkgs_upgrade > 0:
          msg += ngettext("%d package is going to be upgraded.",
                          "%d packages are going to be upgraded.",
                          pkgs_upgrade) % pkgs_upgrade
          msg +=" "
        if downloadSize > 0:
          msg += _("\n\nYou have to download a total of %s. ") %\
              apt_pkg.SizeToStr(downloadSize)
          msg += self.getFetchProgress().estimatedDownloadTime(downloadSize)
        if (pkgs_upgrade + pkgs_inst + pkgs_remove) > 100:
          msg += "\n\n%s" % _( "Fetching and installing the upgrade "
                               "can take several hours. Once the download "
                               "has finished, the process cannot be cancelled.")
        # Show an error if no actions are planned
        if (pkgs_upgrade + pkgs_inst + pkgs_remove) < 1:
          # FIXME: this should go into DistUpgradeController
          summary = _("Your system is up-to-date")
          msg = _("There are no upgrades available for your system. "
                  "The upgrade will now be canceled.")
          self.error(summary, msg)
          return False
        # set the message
        self.confirmChangesMessage = msg
        return True

    def askYesNoQuestion(self, summary, msg, default='No'):
        " ask a Yes/No question and return True on 'Yes' "
        pass
    def confirmRestart(self):
        " generic ask about the restart, can be overridden "
        summary = _("Reboot required")
        msg =  _("The upgrade is finished and "
                 "a reboot is required. "
                 "Do you want to do this "
                 "now?")
        return self.askYesNoQuestion(summary, msg)
    def error(self, summary, msg, extended_msg=None):
        " display a error "
        pass
    def information(self, summary, msg, extended_msg=None):
        " display a information msg"
        pass
    def processEvents(self):
        """ process gui events (to keep the gui alive during a long
            computation """
        pass
    def showDemotions(self, summary, msg, demotions):
      """
      show demoted packages to the user, default implementation
      is to just show a information dialog
      """
      self.information(summary, msg, "\n".join(demotions))

if __name__ == "__main__":
  fp = FetchProgress()
  fp.pulse()
