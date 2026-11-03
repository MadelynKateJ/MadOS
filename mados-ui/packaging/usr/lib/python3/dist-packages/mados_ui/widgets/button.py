import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk


class MadButton(Gtk.Button):

    def __init__(self, text):

        Gtk.Button.__init__(self)

        self.set_label(text)

        self.set_hexpand(True)

        style = self.get_style_context()

        style.add_class("suggested-action")
        style.add_class("mad-button")
