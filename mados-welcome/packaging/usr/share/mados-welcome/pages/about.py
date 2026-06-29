import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk


class AboutPage(Gtk.Box):

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
            "<span size='22000' weight='bold'>ℹ About MadOS</span>"
        )
        title.set_xalign(0)

        self.pack_start(title, False, False, 0)

        info = Gtk.Label()
        info.set_xalign(0)
        info.set_markup(
            "<b>MadOS Alpha</b>\n\n"
            "Built with ❤️ by Madelyn.\n\n"
            "Based on Linux Mint.\n"
            "Powered by GTK 3.\n\n"
            "Version: 0.2 Alpha"
        )

        self.pack_start(info, False, False, 0)

        license_button = Gtk.Button(label="View License (Coming Soon)")
        self.pack_start(license_button, False, False, 10)
