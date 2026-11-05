import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk


class MadSidebar(Gtk.Box):

    def __init__(self):

        Gtk.Box.__init__(
            self,
            orientation=Gtk.Orientation.VERTICAL,
            spacing=8
        )

        self.set_size_request(230, -1)

        self.set_margin_top(20)
        self.set_margin_bottom(20)
        self.set_margin_start(20)
        self.set_margin_end(20)

        self.buttons = {}

        self.callback = None

    ##################################################

    def connect_page_changed(
        self,
        callback
    ):

        self.callback = callback

    ##################################################

    def add_page(
        self,
        icon,
        title
    ):

        button = Gtk.Button()

        button.get_style_context().add_class(
            "mad-sidebar-button"
        )

        row = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=12
        )

        image = Gtk.Label(
            label=icon
        )

        text = Gtk.Label(
            label=title
        )

        text.set_xalign(0)

        row.pack_start(
            image,
            False,
            False,
            0
        )

        row.pack_start(
            text,
            True,
            True,
            0
        )

        button.add(row)

        button.connect(
            "clicked",
            self.clicked,
            title
        )

        self.pack_start(
            button,
            False,
            False,
            0
        )

        self.buttons[title] = button

    ##################################################

    def clicked(
        self,
        button,
        page
    ):

        self.select(page)

        if self.callback:

            self.callback(page)

    ##################################################

    def select(
        self,
        page
    ):

        for name, button in self.buttons.items():

            button.set_sensitive(
                name != page
            )
