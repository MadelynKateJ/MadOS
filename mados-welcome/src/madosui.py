import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk


####################################################
# Section Title
####################################################

class MadSection(Gtk.Label):

    def __init__(self, text):

        Gtk.Label.__init__(self)

        self.set_xalign(0)

        self.set_markup(
            f"<span size='22000' weight='bold'>{text}</span>"
        )


####################################################
# Pink Button
####################################################

class MadButton(Gtk.Button):

    def __init__(self, text):

        Gtk.Button.__init__(self, label=text)

        self.set_hexpand(True)

        style = self.get_style_context()

        style.add_class("suggested-action")
        style.add_class("mad-button")


####################################################
# Card
####################################################

class MadCard(Gtk.Frame):

    def __init__(self, title):

        Gtk.Frame.__init__(self)

        self.set_shadow_type(Gtk.ShadowType.NONE)

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
            f"<span size='16000' weight='bold'>{title}</span>"
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


####################################################
# Status Row
####################################################

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
