import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk

import launcher
import systeminfo
from madosui import MadCard, MadButton, MadStatusRow, MadSection


class HomePage(Gtk.Box):

    def __init__(self):

        Gtk.Box.__init__(
            self,
            orientation=Gtk.Orientation.VERTICAL,
            spacing=25
        )

        self.set_margin_top(35)
        self.set_margin_bottom(35)
        self.set_margin_start(35)
        self.set_margin_end(35)

        ###################################################
        # Welcome
        ###################################################

        title = MadSection("🌸 Welcome to MadOS")
        self.pack_start(title, False, False, 0)

        subtitle = Gtk.Label(
            label="Everything you need, all in one place."
        )
        subtitle.set_xalign(0)

        self.pack_start(subtitle, False, False, 0)

        ###################################################
        # Layout
        ###################################################

        columns = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=20
        )

        self.pack_start(columns, True, True, 0)

        left = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=20
        )

        right = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=20
        )

        columns.pack_start(left, True, True, 0)
        columns.pack_start(right, True, True, 0)

        ###################################################
        # System Status
        ###################################################

        system = MadCard("🖥 System Status")

        rows = [

            MadStatusRow(
                "Internet",
                "🟢 Connected"
                if systeminfo.internet_connected()
                else "🔴 Offline"
            ),

            MadStatusRow(
                "Steam",
                "🟢 Installed"
                if systeminfo.steam_installed()
                else "⚪ Not Installed"
            ),

            MadStatusRow(
                "Graphics",
                "🟢 NVIDIA"
                if systeminfo.nvidia_installed()
                else "🟢 AMD / Intel"
            ),

            MadStatusRow(
                "Memory",
                systeminfo.get_memory()
            ),

            MadStatusRow(
                "Storage",
                systeminfo.get_disk()
            ),

            MadStatusRow(
                "CPU",
                systeminfo.get_cpu()
            ),

            MadStatusRow(
                "Version",
                systeminfo.get_mados_version()
            )

        ]

        for row in rows:
            system.content.pack_start(
                row,
                False,
                False,
                0
            )

        left.pack_start(
            system,
            True,
            True,
            0
        )

        ###################################################
        # Quick Actions
        ###################################################

        actions = MadCard("⚡ Quick Actions")

        update = MadButton("🔄 Check for Updates")
        update.connect("clicked", self.check_updates)

        software = MadButton("📦 Software Manager")
        software.connect("clicked", self.open_software)

        settings = MadButton("⚙ System Settings")
        settings.connect("clicked", self.open_settings)

        terminal = MadButton("💻 Terminal")
        terminal.connect("clicked", self.open_terminal)

        files = MadButton("📁 Files")
        files.connect("clicked", self.open_files)

        docs = MadButton("📖 Documentation")
        docs.connect("clicked", self.open_docs)

        actions.content.pack_start(update, False, False, 0)
        actions.content.pack_start(software, False, False, 0)
        actions.content.pack_start(settings, False, False, 0)
        actions.content.pack_start(terminal, False, False, 0)
        actions.content.pack_start(files, False, False, 0)
        actions.content.pack_start(docs, False, False, 0)

        right.pack_start(actions, False, False, 0)

        ###################################################
        # Miso
        ###################################################

        miso = MadCard("🐈 Miso")

        message = Gtk.Label()

        message.set_markup(
            "<span size='16000'>🐈</span>\n\n"
            "<b>Hello, Maddie!</b>\n\n"
            "Everything looks good today.\n\n"
            "Have fun using MadOS!"
        )

        miso.content.pack_start(
            message,
            False,
            False,
            0
        )

        right.pack_start(
            miso,
            True,
            True,
            0
        )

    ###################################################

    def check_updates(self, button):
        launcher.check_updates()

    def open_software(self, button):
        launcher.open_software()

    def open_settings(self, button):
        launcher.open_settings()

    def open_terminal(self, button):
        launcher.open_terminal()

    def open_files(self, button):
        launcher.open_files()

    def open_docs(self, button):
        launcher.open_browser("https://mados.dev")
