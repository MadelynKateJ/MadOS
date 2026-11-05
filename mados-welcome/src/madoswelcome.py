#!/usr/bin/env python3

import os

import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk, Gdk

from pages.home import HomePage
from pages.software import SoftwarePage
from pages.personalize import PersonalizePage
from pages.privacy import PrivacyPage
from pages.community import CommunityPage
from pages.about import AboutPage


class MadOSWelcome(Gtk.Window):

    def __init__(self):

        Gtk.Window.__init__(self, title="MadOS Welcome")

        ##################################################
        # Load MadOS CSS
        ##################################################

        css = Gtk.CssProvider()

        css_path = os.path.join(
            os.path.dirname(__file__),
            "mados.css"
        )

        if os.path.exists(css_path):
            css.load_from_path(css_path)

            Gtk.StyleContext.add_provider_for_screen(
                Gdk.Screen.get_default(),
                css,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            )

        # Then the live MadOS accent on top, so Welcome
        # follows the same accent as the other apps
        from mados_ui.style import MadStyleManager

        MadStyleManager.load()

        ##################################################
        # Window
        ##################################################

        self.set_default_size(1200, 700)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_border_width(0)

        root = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL
        )

        self.add(root)

        ##################################################
        # Sidebar
        ##################################################

        sidebar = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=8
        )

        sidebar.set_size_request(220, -1)

        sidebar.set_margin_top(20)
        sidebar.set_margin_bottom(20)
        sidebar.set_margin_start(15)
        sidebar.set_margin_end(15)

        root.pack_start(
            sidebar,
            False,
            False,
            0
        )

        ##################################################
        # Logo
        ##################################################

        logo = Gtk.Label()

        logo.set_markup(
            "<span size='24000' weight='bold'>🌸 MadOS</span>"
        )

        sidebar.pack_start(
            logo,
            False,
            False,
            15
        )

        ##################################################
        # Main Stack
        ##################################################

        self.stack = Gtk.Stack()

        self.stack.set_transition_type(
            Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
        )

        self.stack.set_transition_duration(250)

        root.pack_start(
            self.stack,
            True,
            True,
            0
        )

        ##################################################
        # Pages
        ##################################################

        pages = [

            ("🏠 Home", HomePage()),

            ("📦 Software", SoftwarePage()),

            ("🎨 Personalize", PersonalizePage()),

            ("🔒 Privacy", PrivacyPage()),

            ("💬 Community", CommunityPage()),

            ("ℹ About", AboutPage())

        ]

        for title, page in pages:

            self.stack.add_named(
                page,
                title
            )

            button = Gtk.Button(
                label=title
            )

            button.get_style_context().add_class(
                "mad-sidebar-button"
            )

            button.connect(
                "clicked",
                self.change_page,
                title
            )

            sidebar.pack_start(
                button,
                False,
                False,
                0
            )

        ##################################################
        # Footer
        ##################################################

        footer = Gtk.Label()

        footer.set_markup(
            "<small>MadOS Alpha</small>"
        )

        sidebar.pack_end(
            footer,
            False,
            False,
            10
        )

        self.stack.set_visible_child_name(
            "🏠 Home"
        )

    ##################################################

    def change_page(
        self,
        button,
        page
    ):

        self.stack.set_visible_child_name(page)


##################################################

win = MadOSWelcome()

win.connect(
    "destroy",
    Gtk.main_quit
)

win.show_all()

Gtk.main()
