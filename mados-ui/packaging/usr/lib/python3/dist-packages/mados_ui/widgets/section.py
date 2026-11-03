import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk
from xml.sax.saxutils import escape


class MadSection(Gtk.Label):

    def __init__(self, text):

        Gtk.Label.__init__(self)

        self.set_xalign(0)

        self.set_markup(
            f"<span size='22000' weight='bold'>{escape(text)}</span>"
        )
