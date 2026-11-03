import os

from .settings import Settings


CONFIG_DIR = os.path.expanduser("~/.config/mados")
THEME_FILE = os.path.join(CONFIG_DIR, "theme.css")


ACCENTS = {

    "pink": "#ff4fa3",

    "purple": "#a855f7",

    "blue": "#3b82f6",

    "green": "#22c55e",

    "orange": "#f97316"

}


class ThemeManager:

    def __init__(self):

        self.settings = Settings()

    ##################################################

    def apply(self):

        os.makedirs(
            CONFIG_DIR,
            exist_ok=True
        )

        accent = self.settings.get_accent()

        colour = ACCENTS.get(
            accent,
            ACCENTS["pink"]
        )

        css = f"""
button.suggested-action {{
    background: {colour};
    border-color: {colour};
}}

button {{
    border-radius: 10px;
}}

selection {{
    background: {colour};
}}

.accent {{
    background: {colour};
}}

.accent-text {{
    color: {colour};
}}
"""

        with open(THEME_FILE, "w") as file:

            file.write(css)
