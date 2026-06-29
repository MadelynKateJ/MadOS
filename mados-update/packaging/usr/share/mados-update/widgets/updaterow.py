import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk


class UpdateRow(Gtk.Frame):

    def __init__(self, update):

        Gtk.Frame.__init__(self)

        self.package = update

        self.set_shadow_type(Gtk.ShadowType.NONE)

        ##################################################

        outer = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=15
        )

        outer.set_margin_top(15)
        outer.set_margin_bottom(15)
        outer.set_margin_start(15)
        outer.set_margin_end(15)

        self.add(outer)

        ##################################################
        # Checkbox
        ##################################################

        self.checkbox = Gtk.CheckButton()

        self.checkbox.set_active(True)

        outer.pack_start(
            self.checkbox,
            False,
            False,
            0
        )

        ##################################################
        # Information
        ##################################################

        info = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=5
        )

        outer.pack_start(
            info,
            True,
            True,
            0
        )

        ##################################################

        title = Gtk.Label()

        title.set_xalign(0)

        title.set_markup(
            f"<b>{update['name']}</b>"
        )

        info.pack_start(
            title,
            False,
            False,
            0
        )

        ##################################################

        description = Gtk.Label()

        description.set_xalign(0)

        description.set_line_wrap(True)

        description.set_text(
            update["description"]
        )

        info.pack_start(
            description,
            False,
            False,
            0
        )

        ##################################################

        versions = Gtk.Label()

        versions.set_xalign(0)

        versions.set_markup(
            f"<small>Current: {update['installed']}\nAvailable: {update['candidate']}</small>"
        )

        info.pack_start(
            versions,
            False,
            False,
            0
        )

    ##################################################

    def is_selected(self):

        return self.checkbox.get_active()

    ##################################################

    def set_selected(self, value):

        self.checkbox.set_active(value)
