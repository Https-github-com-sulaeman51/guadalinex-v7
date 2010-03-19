# -*- coding: utf-8 -*-

from buildbot.steps.shell import ShellCommand, WithProperties
from buildbot.steps.transfer import FileUpload
from buildbot.status.builder import SUCCESS, FAILURE, WARNINGS

import distroconf
from distroconf import upload_dir, halt_on_lintian_error, halt_on_unittest_error
from distroconf import path, derivative, livehelper, pdebuild, repo_dir, codename

class RemoveSVN(ShellCommand):
    """ Removes the .svn directories recursively"""

    name = "RemoveSVN"
    command = ["rm", "-rf", "$(find -name .svn)"]
    description = [name]

    def __init__(self, **kwargs):
        ShellCommand.__init__(self, **kwargs)

class PBuildPkg(ShellCommand):
    """Perfoms the building of a package with pdebuild
    It counts and logs lintian error and lintian warnings.
    On lintian errors can return FAILURE if distroconf.halt_on_lintian_error 
    it's True.
    """

    name = "PBuildPkg"
    command = pdebuild
    description = [name]

    def __init__(self, **kwargs):
	ShellCommand.__init__(self, **kwargs)

    def createSummary(self, log):
        warning_log = []
        error_log = []
	self.descriptionDone = [self.name]

        for line in log.readlines():
            if line.strip().startswith("W:"):
                warning_log.append(line)
            if line.strip().startswith("E:"):
                error_log.append(line)

        self.warnings = len(warning_log)
        self.errors = len(error_log)

        if self.warnings:
            self.addCompleteLog('Warnings', "".join(warning_log))
            self.descriptionDone.append("warn=%d" % self.warnings)

        if self.errors:
            self.addCompleteLog('Errors', "".join(error_log))
            self.descriptionDone.append("err=%d" % self.errors)

    def evaluateCommand(self, cmd):
	"""
	Evaluates the result of pdebuild command.

	If lintian errors are founded it can return
	FAILURE or WARNINGS depending on distroconf.halt_on_lintian_errors
	"""
        if cmd.rc != 0:
            return FAILURE
        if self.errors:
	    if halt_on_lintian_error:
	        return FAILURE
	    else:
		return WARNINGS
        if self.warnings:
            return WARNINGS
        return SUCCESS


class GCSBuild(PBuildPkg):
    """It performs the building of a gcs package."""
    name = "GCSBuild"
    command = ["gcs_build"]
    description = [name]

    def __init__(self, **kwargs):
	PBuildPkg.__init__(self, **kwargs)

class SetSVNRev(ShellCommand):
    """
    In gcs packages, it sets the svn-revision as package version/revision.
    """
    name = "SetSVNRev"
    command = ["sed", "-i", WithProperties("s/^version\:.*/version\: v6r%s/g", "got_revision"), "gcs/info"]
    description = [name]

    def __init__(self, **kwargs):
        ShellCommand.__init__(self, **kwargs)


class Unittests(ShellCommand):
    """
    Run the package's unittest suite.
    It run WARNINGS if can't find the 'unittests' executable.
    It parses warnings and errors and can return FAILURE on unittest
    errors if distroconf.halt_on_unittest_errors it's True.
    """
    name = "Unittests"
    command = ["bash", "unittests"]
    description = [name]

    def __init__(self, **kwargs):
	ShellCommand.__init__(self, **kwargs)

    def createSummary(self, log):
        warning_log = []
        error_log = []
	self.descriptionDone = [self.name]

        for line in log.readlines():
            if line.strip().startswith("WARNING:"):
                warning_log.append(line)
            if line.strip().startswith("FAIL:"):
                error_log.append(line)

        self.warnings = len(warning_log)
        self.errors = len(error_log)

        if self.warnings:
            self.addCompleteLog('Warnings', "".join(warning_log))
            self.descriptionDone.append("warn=%d" % self.warnings)

        if self.errors:
            self.addCompleteLog('Errors', "".join(error_log))
            self.descriptionDone.append("err=%d" % self.errors)

    def evaluateCommand(self, cmd):
        """
        Evaluate the status of unittests execution

        If there is no unittest executable the code 127 
        it's retured. It throws WARNINGS.
        """

        if cmd.rc == 127:
                return WARNINGS
        elif cmd.rc != 0:
            if halt_on_unittest_error:
                return FAILURE
            else:
                return WARNINGS

        if self.warnings or self.errors:
            return WARNINGS
        return SUCCESS


class Reprepro(ShellCommand):
    name = "Reprepro"
    description = [name]
    command = ["sh", "-c",\
        "reprepro --ignore=wrongdistribution -VVV -b%(repo)s include %(codename)s %(package)s; rm -f ../*.deb ../*.dsc ../*.tar.gz ../*.changes ../*.build" \
            %  {'repo': repo_dir,\
                'codename': codename,\
                'package': '../*i386.changes'}]

    def __init__(self, **kwargs):
        ShellCommand.__init__(self, **kwargs)

class RepoAddBinPkgs(ShellCommand):
    name = "RepoAddBinPkgs"
    description = [name]
    command = ["sh", "-c", "reprepro --ignore=wrongdistribution -VVV -b%(repo)s includedeb %(codename)s %(package)s" \
		    % {'repo': repo_dir,\
		       'codename': codename,\
		       'package': '*.deb'}]

    def __init__(self, **kwargs):
        ShellCommand.__init__(self, **kwargs)

class RepoUpdate(ShellCommand):
    name = "RepoUpdate"
    description = [name]
    command = ["sh", "-c", "reprepro --ignore=wrongdistribution -VVV -b %s update %s" %\
        (distroconf.repo_update_dir, distroconf.repo_update_distro)]

    def __init__(self, **kwargs):
        ShellCommand.__init__(self, **kwargs)

class Reoverride(ShellCommand):
    name = "Reoverride"
    description = [name]
    command = ["sh", "-c", "reprepro --ignore=wrongdistribution -VVV -b %s reoverride %s" %\
        (distroconf.repo_update_dir, distroconf.repo_update_distro)]

    def __init__(self, **kwargs):
        ShellCommand.__init__(self, **kwargs)

class UpdateDerivative(ShellCommand):
    name = "UpdateDerivative"
    command = derivative
    description = [name]
    error_log = None

    def __init__(self, **kwargs):
        ShellCommand.__init__(self, **kwargs)

    def createSummary(self, log):
        warning_log = []

        self.descriptionDone = [self.name]

        for line in log.readlines():
            if line.strip().startswith("Error:"):
                self.error_log = line
            if line.strip().startswith("Warning:"):
                    warning_log.append(line)

        self.warnings = len(warning_log)

        if self.warnings:
            self.addCompleteLog('Warnings', "".join(warning_log))
            self.descriptionDone.append("warn=%d" % self.warnings)

        if self.error_log:
            self.descriptionDone.append("%s" % self.error_log)

    def evaluateCommand(self, cmd):
        if cmd.rc != 0:
                return FAILURE

        if self.error_log:
            return FAILURE

        if self.warnings:
            return WARNINGS

        return SUCCESS


class LiveHelper(ShellCommand):
    name = "livehelper"
    command = livehelper
    description = [name]

    def __init__(self, **kwargs):
        ShellCommand.__init__(self, **kwargs)

    def createSummary(self, log):
        for line in log.readlines():
            if line.strip().startswith("Error:"):
                self.error_log = line

    def evaluateCommand(self, cmd):
        self.descriptionDone = [self.name]

        if cmd.rc == 255:
                self.descriptionDone.append(self.error_log)
                return FAILURE

        if cmd.rc != 0:
                return FAILURE

        return SUCCESS

class SetLiveHelperClientCFG(ShellCommand):
    name = "set-livehelper-client-cfg"
    description = [name]
    command = ["sh", "-c", "cp "+distroconf.livehelper_path+"/config/chroot.client "+distroconf.livehelper_path+"/config/chroot"]

    def __init__(self, **kwargs):
        ShellCommand.__init__(self, **kwargs)

class SetLiveHelperServerCFG(ShellCommand):
    name = "set-livehelper-server-cfg"
    description = [name]
    command = ["sh", "-c", "cp "+distroconf.livehelper_path+"/config/chroot.server "+distroconf.livehelper_path+"/config/chroot"]

    def __init__(self, **kwargs):
        ShellCommand.__init__(self, **kwargs)

class SetRepoPerms(ShellCommand):
    name = "set-repository-perms"
    description = [name]
    command = ["sh", "-c", "sudo chmod -R 755 "+distroconf.repo_dir+"/dists "+distroconf.repo_dir+"/pool"]

    def __init__(self, **kwargs):
        ShellCommand.__init__(self, **kwargs)
