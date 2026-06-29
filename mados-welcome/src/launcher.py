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
# MadOS Launchers
##################################################

def check_updates():
    # Temporary until MadOS Update exists.
    print("MadOS Update is not implemented yet.")


def open_software():
    _launch([
        ["mintinstall"]
    ])


def open_settings():
    _launch([
        ["systemsettings"]
    ])


def open_terminal():
    _launch([
        ["konsole"],
        ["gnome-terminal"]
    ])


def open_files():
    _launch([
        ["dolphin"],
        ["nemo"]
    ])


def open_browser(url):
    _launch([
        ["xdg-open", url]
    ])
