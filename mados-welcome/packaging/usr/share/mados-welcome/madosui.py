import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk


class MadCard(Gtk.Frame):

    def __init__(self, title):

        Gtk.Frame.__init__(self)

        self.set_shadow_type(Gtk.ShadowType.NONE)

        outer = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=15
        )

        outer.set_margin_top(20)
        outer.set_margin_bottom(20)
        outer.set_margin_start(20)
        outer.set_margin_end(20)

        self.add(outer)

        header = Gtk.Label()

        header.set_xalign(0)

        header.set_markup(
            f"<span size='16000' weight='bold'>{title}</span>"
        )

        outer.pack_start(
            header,
            False,
            False,
            0
        )

        self.content = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=10
        )

        outer.pack_start(
            self.content,
            True,
            True,
            0
        )


class MadButton(Gtk.Button):

    def __init__(self, text):

        Gtk.Button.__init__(self)

        self.set_label(text)

        self.set_hexpand(True)

        self.set_margin_top(3)
        self.set_margin_bottom(3)


class MadSection(Gtk.Label):

    def __init__(self, text):

        Gtk.Label.__init__(self)

        self.set_xalign(0)

        self.set_markup(
            f"<span size='22000' weight='bold'>{text}</span>"
        )


class MadStatusRow(Gtk.Box):

    def __init__(self, left, right):

        Gtk.Box.__init__(
            self,
            orientation=Gtk.Orientation.HORIZONTAL
        )

        label_left = Gtk.Label(label=left)
        label_left.set_xalign(0)

        label_right = Gtk.Label(label=right)
        label_right.set_xalign(1)

        self.pack_start(
            label_left,
            True,
            True,
            0
        )

        self.pack_end(
            label_right,
            False,
            False,
            0
        )
