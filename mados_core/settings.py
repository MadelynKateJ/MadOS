import json
import os


CONFIG_DIR = os.path.expanduser(
    "~/.config/mados"
)

CONFIG_FILE = os.path.join(
    CONFIG_DIR,
    "settings.json"
)


DEFAULT_SETTINGS = {

    "accent": "pink",

    "dark_mode": True,

    "wallpaper": "",

    "animations": True

}


class Settings:

    def __init__(self):

        os.makedirs(
            CONFIG_DIR,
            exist_ok=True
        )

        if not os.path.exists(CONFIG_FILE):

            self.save(DEFAULT_SETTINGS)

    ##################################################

    def load(self):

        with open(CONFIG_FILE) as file:

            return json.load(file)

    ##################################################

    def save(self, data):

        with open(CONFIG_FILE, "w") as file:

            json.dump(
                data,
                file,
                indent=4
            )

    ##################################################

    def get(self, key):

        return self.load().get(
            key,
            DEFAULT_SETTINGS.get(key)
        )

    ##################################################

    def set(self, key, value):

        data = self.load()

        data[key] = value

        self.save(data)

        # Automatically regenerate the theme
        from .theme import ThemeManager

        ThemeManager().apply()

    ##################################################

    def get_accent(self):

        return self.get("accent")

    def set_accent(self, accent):

        self.set(
            "accent",
            accent
        )

    ##################################################

    def get_dark_mode(self):

        return self.get(
            "dark_mode"
        )

    def set_dark_mode(self, enabled):

        self.set(
            "dark_mode",
            enabled
        )

    ##################################################

    def get_wallpaper(self):

        return self.get(
            "wallpaper"
        )

    def set_wallpaper(self, path):

        self.set(
            "wallpaper",
            path
        )

    ##################################################

    def get_animations(self):

        return self.get(
            "animations"
        )

    def set_animations(self, enabled):

        self.set(
            "animations",
            enabled
        )
