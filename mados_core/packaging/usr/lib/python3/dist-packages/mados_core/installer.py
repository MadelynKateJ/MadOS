import subprocess


# dpkg must never stop to ask about a changed configuration
# file: the app has no terminal to answer with, so the prompt
# reads EOF and the whole install dies. confdef takes the
# default action where one exists, confold keeps the user's
# existing file (MadOS branding edits like /etc/issue must
# survive updates, not be overwritten or block them).
DPKG_OPTIONS = [
    "-o",
    "Dpkg::Options::=--force-confdef",
    "-o",
    "Dpkg::Options::=--force-confold"
]


class Installer:

    ##################################################

    def install_selected(self, packages):

        if not packages:
            return False

        command = [
            "pkexec",
            "apt-get",
            "install",
            "--only-upgrade",
            "-y"
        ]

        command.extend(DPKG_OPTIONS)

        command.extend(packages)

        result = subprocess.run(command)

        return result.returncode == 0

    ##################################################

    def install_all(self):

        command = [
            "pkexec",
            "apt-get",
            "dist-upgrade",
            "-y"
        ]

        command.extend(DPKG_OPTIONS)

        result = subprocess.run(command)

        return result.returncode == 0

    ##################################################

    def update_package_lists(self):

        command = [
            "pkexec",
            "apt-get",
            "update"
        ]

        result = subprocess.run(command)

        return result.returncode == 0
