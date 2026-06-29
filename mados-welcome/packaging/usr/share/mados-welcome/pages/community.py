import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk


class CommunityPage(Gtk.Box):

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
            "<span size='22000' weight='bold'>💬 Community</span>"
        )
        title.set_xalign(0)

        self.pack_start(title, False, False, 0)

        description = Gtk.Label(
            label=(
                "Welcome to the MadOS community!\n\n"
                "Eventually you'll be able to:\n"
                "• Join the Discord server\n"
                "• Report bugs\n"
                "• Suggest new features\n"
                "• Read the documentation"
            )
        )
        description.set_xalign(0)

        self.pack_start(description, False, False, 0)

        discord = Gtk.Button(label="Join Discord (Coming Soon)")
        self.pack_start(discord, False, False, 10)
