import os

import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk

from .sidebar import MadSidebar
from .style import MadStyleManager


class MadWindow(Gtk.Window):

    def __init__(self, title):

        Gtk.Window.__init__(self)

        # Load the MadOS stylesheet
        MadStyleManager.load()

        self.set_title(title)
        self.set_default_size(1200, 720)
        self.set_position(Gtk.WindowPosition.CENTER)

        ##################################################

        self.root = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL
        )

        self.add(self.root)

        ##################################################

        header = Gtk.HeaderBar()

        header.set_title(title)
        header.set_show_close_button(True)

        self.set_titlebar(header)

        ##################################################

        body = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL
        )

        self.root.pack_start(
            body,
            True,
            True,
            0
        )

        ##################################################

        self.sidebar = MadSidebar()

        self.sidebar.connect_page_changed(
            self.change_page
        )

        body.pack_start(
            self.sidebar,
            False,
            False,
            0
        )

        ##################################################

        self.stack = Gtk.Stack()

        self.stack.set_transition_type(
            Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
        )

        self.stack.set_transition_duration(250)

        body.pack_start(
            self.stack,
            True,
            True,
            0
        )

    ##################################################

    def add_page(
        self,
        title,
        widget,
        icon="📄"
    ):

        self.stack.add_named(
            widget,
            title
        )

        self.sidebar.add_page(
            icon,
            title
        )

    ##################################################

    def change_page(self, page):

        self.stack.set_visible_child_name(page)
