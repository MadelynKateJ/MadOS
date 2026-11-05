#!/usr/bin/env python3

import os
import subprocess

import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk

from mados_core import Settings

from mados_ui import (
    MadWindow,
    MadSection,
    MadCard,
    MadButton
)

from mados_ui.style import MadStyleManager


class SettingsWindow(MadWindow):

    def __init__(self):

        super().__init__("🌸 MadOS Settings")

        self.add_page("Appearance", self.appearance_page(), "🎨")
        self.add_page("Displays", self.module_page("Displays", "kcm_kscreen"), "🖥")
        self.add_page("Sound", self.module_page("Sound", "kcm_pulseaudio"), "🔊")
        self.add_page("Network", self.module_page("Network", "kcm_networkmanagement"), "🌐")
        self.add_page("Keyboard", self.module_page("Keyboard", "kcm_keyboard"), "⌨")
        self.add_page("Mouse", self.module_page("Mouse", "kcm_mouse"), "🖱")
        self.add_page("Users", self.module_page("Users", "kcm_users"), "👤")
        self.add_page("Privacy", self.module_page("Privacy", "kcm_feedback"), "🔒")
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

    def module_page(self, title, module):

        # Until MadOS grows its own page for this, open the
        # real Plasma settings module so the button does
        # something true instead of promising "coming soon".

        page = self.page(title)

        card = MadCard(title)

        label = Gtk.Label(
            label="Managed in Plasma's settings for now."
        )

        label.set_xalign(0)

        card.content.pack_start(
            label,
            False,
            False,
            0
        )

        button = MadButton("Open")

        button.connect(
            "clicked",
            lambda b: subprocess.Popen(
                ["kcmshell6", module]
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

    def appearance_page(self):

        page = self.page("Appearance")

        card = MadCard("Mode")

        label = Gtk.Label(
            label="Dark or light, for the MadOS apps."
        )

        label.set_xalign(0)

        card.content.pack_start(
            label,
            False,
            False,
            0
        )

        row = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=10
        )

        text = Gtk.Label(label="Dark Mode")

        text.set_xalign(0)

        row.pack_start(text, True, True, 0)

        self.dark_switch = Gtk.Switch()

        self.dark_switch.set_active(
            Settings().get_dark_mode()
        )

        self.dark_switch.connect(
            "notify::active",
            self.dark_mode_toggled
        )

        row.pack_start(
            self.dark_switch,
            False,
            False,
            0
        )

        card.content.pack_start(
            row,
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

    def dark_mode_toggled(self, switch, param):

        dark = switch.get_active()

        Settings().set_dark_mode(dark)

        MadStyleManager.load()

        # The Sakura pair: dusk picture for dark mode,
        # the pale one for light
        image = (
            "mados-sakura-dusk.jpg"
            if dark
            else "mados-sakura-wallpaper.jpg"
        )

        path = os.path.expanduser(
            os.path.join("~", "Pictures", image)
        )

        if os.path.exists(path):

            subprocess.Popen(
                ["plasma-apply-wallpaperimage", path]
            )

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
