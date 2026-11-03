import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk, Gdk

from mados_core import Settings


class MadStyleManager:

    provider = None

    COLOURS = {

        "pink": "#ff4fa3",
        "purple": "#a855f7",
        "blue": "#3b82f6",
        "green": "#22c55e",
        "orange": "#f97316"

    }

    @classmethod
    def load(cls):

        accent = Settings().get_accent()

        colour = cls.COLOURS.get(
            accent,
            cls.COLOURS["pink"]
        )

        css = f"""

button.mad-button {{

    background-image: none;
    background-color: {colour};

    color: white;

    border-radius: 12px;

    border: 1px solid {colour};

    padding: 10px;

}}

button.mad-button:hover {{

    background-image: none;
    background-color: {colour};

}}

"""

        provider = Gtk.CssProvider()

        provider.load_from_data(
            css.encode()
        )

        screen = Gdk.Screen.get_default()

        if cls.provider:

            Gtk.StyleContext.remove_provider_for_screen(
                screen,
                cls.provider
            )

        Gtk.StyleContext.add_provider_for_screen(

            screen,

            provider,

            Gtk.STYLE_PROVIDER_PRIORITY_USER

        )

        cls.provider = provider
