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

    def __init__(self):

        # What the last command actually said, kept so the UI
        # can show the user a real reason instead of a shrug.
        # (Until 0.1.2 the output went nowhere and every failure
        # read "failed or was cancelled", even when apt had
        # printed exactly what was wrong.)
        self.last_output = ""
        self.last_returncode = None

    ##################################################

    def _run(self, command):

        try:

            result = subprocess.run(
                command,
                capture_output=True,
                text=True
            )

            self.last_returncode = result.returncode

            self.last_output = (
                (result.stdout or "") + (result.stderr or "")
            ).strip()

            return result.returncode == 0

        except Exception as exc:

            self.last_returncode = None

            self.last_output = str(exc)

            return False

    ##################################################

    def last_summary(self):
        """One short human sentence about the last failure."""

        if self.last_returncode == 126:

            return "the password prompt was dismissed"

        if self.last_returncode == 127:

            return "the password prompt could not be shown"

        errors = [
            line.strip()
            for line in self.last_output.splitlines()
            if line.strip().startswith("E:")
        ]

        if errors:
            return errors[-1][2:].strip()

        lines = [
            line.strip()
            for line in self.last_output.splitlines()
            if line.strip()
        ]

        if lines:
            return lines[-1]

        return "no details were reported"

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

        return self._run(command)

    ##################################################

    def install_all(self):

        command = [
            "pkexec",
            "apt-get",
            "dist-upgrade",
            "-y"
        ]

        command.extend(DPKG_OPTIONS)

        return self._run(command)

    ##################################################

    def update_package_lists(self):

        command = [
            "pkexec",
            "apt-get",
            "update"
        ]

        return self._run(command)
