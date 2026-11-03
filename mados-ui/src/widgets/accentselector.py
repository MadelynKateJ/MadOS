import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk

from mados_core import Settings


ACCENTS = [
    ("🩷", "pink", "Pink"),
    ("💜", "purple", "Purple"),
    ("💙", "blue", "Blue"),
    ("💚", "green", "Green"),
    ("🧡", "orange", "Orange"),
]


class AccentCard(Gtk.Button):

    def __init__(self, emoji, colour, name):

        super().__init__()

        self.colour = colour
        self.emoji = emoji
        self.name = name

        box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=8
        )

        box.set_margin_top(15)
        box.set_margin_bottom(15)
        box.set_margin_start(15)
        box.set_margin_end(15)

        self.heart = Gtk.Label()
        self.title = Gtk.Label()
        self.check = Gtk.Label()

        self.heart.set_markup(
            f"<span size='26000'>{emoji}</span>"
        )

        self.title.set_markup(
            f"<b>{name}</b>"
        )

        self.check.set_text("")

        box.pack_start(self.heart, False, False, 0)
        box.pack_start(self.title, False, False, 0)
        box.pack_start(self.check, False, False, 0)

        self.add(box)

    def set_selected(self, selected):

        if selected:
            self.check.set_markup("<b>✓ Selected</b>")
        else:
            self.check.set_text("")


class MadAccentSelector(Gtk.Box):

    def __init__(self):

        super().__init__(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=20
        )

        self.settings = Settings()

        flow = Gtk.FlowBox()
        flow.set_max_children_per_line(5)
        flow.set_selection_mode(Gtk.SelectionMode.NONE)

        self.pack_start(flow, False, False, 0)

        self.current = Gtk.Label()
        self.current.set_xalign(0)

        self.pack_start(self.current, False, False, 0)

        self.cards = {}

        for emoji, colour, name in ACCENTS:

            card = AccentCard(
                emoji,
                colour,
                name
            )

            card.connect(
                "clicked",
                self.clicked,
                colour
            )

            flow.add(card)

            self.cards[colour] = card

        self.refresh()

    def clicked(self, button, colour):

        self.settings.set_accent(colour)

        self.refresh()

    def refresh(self):

        current = self.settings.get_accent()

        for colour, card in self.cards.items():

            card.set_selected(colour == current)

        card = self.cards[current]

        if current == "pink":

            self.current.set_markup(
                "<b>Current Accent</b>\n🩷 Pink (MadOS Default)"
            )

        else:

            self.current.set_markup(
                f"<b>Current Accent</b>\n{card.emoji} {card.name}"
            )
