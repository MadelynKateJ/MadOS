import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk


class MadStatusRow(Gtk.Box):

    def __init__(self, left, right):

        Gtk.Box.__init__(
            self,
            orientation=Gtk.Orientation.HORIZONTAL
        )

        left_label = Gtk.Label(label=left)
        left_label.set_xalign(0)

        right_label = Gtk.Label(label=right)
        right_label.set_xalign(1)

        self.pack_start(
            left_label,
            True,
            True,
            0
        )

        self.pack_end(
            right_label,
            False,
            False,
            0
        )
