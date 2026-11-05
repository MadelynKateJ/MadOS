import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

import launcher


class SoftwarePage(Gtk.Box):

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
            "<span size='22000' weight='bold'>📦 Software</span>"
        )
        title.set_xalign(0)

        self.pack_start(title, False, False, 0)

        description = Gtk.Label(
            label="Install applications, games and development tools."
        )
        description.set_xalign(0)

        self.pack_start(description, False, False, 0)

        store = Gtk.Button(label="🛍 Open Software Centre")
        store.connect(
            "clicked",
            lambda b: launcher.open_software()
        )
        self.pack_start(store, False, False, 10)

        update = Gtk.Button(label="🔄 Check for Updates")
        update.connect(
            "clicked",
            lambda b: launcher.check_updates()
        )
        self.pack_start(update, False, False, 10)
