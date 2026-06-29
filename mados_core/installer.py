import subprocess


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
