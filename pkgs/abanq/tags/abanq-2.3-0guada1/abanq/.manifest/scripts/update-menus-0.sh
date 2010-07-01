#! /bin/sh
exec 1>&-
exec 2>&-
if which update-menus 2> /dev/null > /dev/null || type -p update-menus 2> /dev/null >/dev/null; then update-menus 2> /dev/null; fi
if which kbuildsycoca 2> /dev/null > /dev/null || type -p kbuildsycoca 2> /dev/null >/dev/null; then kbuildsycoca 2>/dev/null; fi
if which dtaction 2> /dev/null > /dev/null || type -p dtaction 2> /dev/null > /dev/null; then dtaction ReloadActions 2>/dev/null; dtaction RestorePanel 2>/dev/null; fi
true
