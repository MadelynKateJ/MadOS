import os

import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk, Gdk

from mados_core import Settings
from mados_core.theme import THEME_FILE


class MadStyleManager:

    provider = None
    theme_provider = None

    COLOURS = {

        "pink": "#ff4fa3",
        "purple": "#a855f7",
        "blue": "#3b82f6",
        "green": "#22c55e",
        "orange": "#f97316"

    }

    @classmethod
    def load(cls):

        settings = Settings()

        accent = settings.get_accent()

        colour = cls.COLOURS.get(
            accent,
            cls.COLOURS["pink"]
        )

        dark = settings.get_dark_mode()

        gtk_settings = Gtk.Settings.get_default()

        if gtk_settings:

            gtk_settings.set_property(
                "gtk-application-prefer-dark-theme",
                bool(dark)
            )

        base = ""

        if dark:

            base = """

window {

    background-color: rgba(46, 30, 42, 0.80);
    color: #f5f5f5;

}

label {

    color: #f5f5f5;

}

"""

        css = base + f"""

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

button.mad-sidebar-button {{

    background-image: none;
    background-color: {colour};

    color: white;

    border-radius: 12px;

    border: 1px solid {colour};

    padding: 10px;

}}

button.accent-card {{

    border-radius: 12px;

}}

button.accent-card-selected {{

    background-image: none;

    border: 3px solid {colour};

}}

"""

        screen = Gdk.Screen.get_default()

        # The shared theme file ThemeManager regenerates on
        # every settings change (suggested-action, selection,
        # .accent) — load it too, or nothing ever reads it.
        if cls.theme_provider:

            Gtk.StyleContext.remove_provider_for_screen(
                screen,
                cls.theme_provider
            )

            cls.theme_provider = None

        if os.path.exists(THEME_FILE):

            theme_provider = Gtk.CssProvider()

            theme_provider.load_from_path(
                THEME_FILE
            )

            Gtk.StyleContext.add_provider_for_screen(

                screen,

                theme_provider,

                Gtk.STYLE_PROVIDER_PRIORITY_USER

            )

            cls.theme_provider = theme_provider

        provider = Gtk.CssProvider()

        provider.load_from_data(
            css.encode()
        )

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
