import shutil
import subprocess


def _launch(programs):

    for program in programs:

        if shutil.which(program[0]):

            try:
                subprocess.Popen(program)
                return True
            except Exception as e:
                print(e)

    return False


##################################################
# MadOS Applications
##################################################

def check_updates():
    return _launch([
        ["mados-update"],
        ["mintupdate"]
    ])


def open_software():
    return _launch([
        ["mados-store"],
        ["mintinstall"]
    ])


def open_settings():
    return _launch([
        ["mados-settings"],
        ["systemsettings"],
        ["gnome-control-center"]
    ])


def open_terminal():
    return _launch([
        ["konsole"],
        ["gnome-terminal"],
        ["xterm"]
    ])


def open_files():
    return _launch([
        ["dolphin"],
        ["nemo"]
    ])


def open_browser(url):
    return _launch([
        ["xdg-open", url]
    ])
