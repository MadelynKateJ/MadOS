import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

import launcher


class PersonalizePage(Gtk.Box):

    def __init__(self):

        Gtk.Box.__init__(
            self,
            orientation=Gtk.Orientation.VERTICAL,
            spacing=20
        )

        self.set_margin_top(30)
        self.set_margin_bottom(30)
        self.set_margin_start(30)
        self.set_margin_end(30)

        title = Gtk.Label()
        title.set_markup(
            "<span size='22000' weight='bold'>🎨 Personalize</span>"
        )
        title.set_xalign(0)

        self.pack_start(title, False, False, 0)

        description = Gtk.Label(
            label="Customize MadOS to match your style."
        )
        description.set_xalign(0)

        self.pack_start(description, False, False, 0)

        button = Gtk.Button(label="Open Appearance Settings")
        button.connect(
            "clicked",
            lambda b: launcher.open_settings()
        )
        self.pack_start(button, False, False, 10)
