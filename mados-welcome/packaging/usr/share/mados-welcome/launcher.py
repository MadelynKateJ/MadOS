import shutil
import subprocess


def _launch(programs):

    for program in programs:

        executable = program[0]

        if shutil.which(executable):

            try:
                subprocess.Popen(program)
                return True
            except Exception as e:
                print(e)

    return False


##################################################
# Applications
##################################################

def check_updates():
    return _launch([
        ["mados-update"],
        ["mintupdate"]
    ])


def open_software():
    return _launch([
        ["mados-software"],
        ["mintinstall"]
    ])


def open_settings():
    return _launch([
        ["mados-settings"],
        ["gnome-control-center"],
        ["systemsettings"]
    ])


def open_terminal():
    return _launch([
        ["kgx"],
        ["gnome-terminal"],
        ["konsole"],
        ["xterm"]
    ])


def open_files():
    return _launch([
        ["nemo"],
        ["dolphin"],
        ["nautilus"]
    ])


def open_browser(url):
    return _launch([
        ["xdg-open", url]
    ])
