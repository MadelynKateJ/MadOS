#!/usr/bin/env python3

import subprocess

import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk

from mados_ui import (
    MadWindow,
    MadSection,
    MadCard,
    MadButton,
    MadAccentSelector
)


class SettingsWindow(MadWindow):

    def __init__(self):

        super().__init__("🌸 MadOS Settings")

        self.add_page("Appearance", self.appearance_page(), "🎨")
        self.add_page("Displays", self.simple_page("Displays"), "🖥")
        self.add_page("Sound", self.simple_page("Sound"), "🔊")
        self.add_page("Network", self.simple_page("Network"), "🌐")
        self.add_page("Keyboard", self.simple_page("Keyboard"), "⌨")
        self.add_page("Mouse", self.simple_page("Mouse"), "🖱")
        self.add_page("Users", self.simple_page("Users"), "👤")
        self.add_page("Privacy", self.simple_page("Privacy"), "🔒")
        self.add_page("Updates", self.updates_page(), "⬆")
        self.add_page("About", self.about_page(), "ℹ")

        self.change_page("Appearance")

    ##################################################

    def page(self, title):

        box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=20
        )

        box.set_margin_top(25)
        box.set_margin_bottom(25)
        box.set_margin_start(25)
        box.set_margin_end(25)

        box.pack_start(
            MadSection(title),
            False,
            False,
            0
        )

        return box

    ##################################################

    def simple_page(self, title):

        page = self.page(title)

        card = MadCard(title)

        label = Gtk.Label(
            label="Coming soon."
        )

        label.set_xalign(0)

        card.content.pack_start(
            label,
            False,
            False,
            0
        )

        page.pack_start(
            card,
            False,
            False,
            0
        )

        return page

    ##################################################

    def appearance_page(self):

        page = self.page("Appearance")

        accent = MadCard("Accent Colour")

        accent.content.pack_start(
            MadAccentSelector(),
            False,
            False,
            0
        )

        page.pack_start(
            accent,
            False,
            False,
            0
        )

        return page

    ##################################################

    def updates_page(self):

        page = self.page("Updates")

        card = MadCard("System Updates")

        button = MadButton(
            "Open MadOS Update"
        )

        button.connect(
            "clicked",
            lambda b: subprocess.Popen(
                ["mados-update"]
            )
        )

        card.content.pack_start(
            button,
            False,
            False,
            0
        )

        page.pack_start(
            card,
            False,
            False,
            0
        )

        return page

    ##################################################

    def about_page(self):

        page = self.page("About")

        card = MadCard("MadOS")

        label = Gtk.Label()

        label.set_xalign(0)

        label.set_markup(
            "<b>MadOS Alpha</b>\n\n"
            "Shared UI Framework\n"
            "Shared Core Framework\n"
            "GTK 3\n"
            "Python 3"
        )

        card.content.pack_start(
            label,
            False,
            False,
            0
        )

        page.pack_start(
            card,
            False,
            False,
            0
        )

        return page


win = SettingsWindow()

win.connect(
    "destroy",
    Gtk.main_quit
)

win.show_all()

Gtk.main()
