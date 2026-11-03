import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk

from xml.sax.saxutils import escape


class MadCard(Gtk.Frame):

    def __init__(self, title):

        Gtk.Frame.__init__(self)

        self.set_shadow_type(
            Gtk.ShadowType.NONE
        )

        box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=12
        )

        box.set_margin_top(18)
        box.set_margin_bottom(18)
        box.set_margin_start(18)
        box.set_margin_end(18)

        self.add(box)

        heading = Gtk.Label()

        heading.set_xalign(0)

        heading.set_markup(
            f"<span size='16000' weight='bold'>{escape(title)}</span>"
        )

        box.pack_start(
            heading,
            False,
            False,
            0
        )

        self.content = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=10
        )

        box.pack_start(
            self.content,
            True,
            True,
            0
        )
