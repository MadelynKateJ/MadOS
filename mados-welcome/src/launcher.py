# Welcome's launchers live in the shared core framework
# (mados_core.launcher) so every MadOS app opens the same
# programs the same way. This module only re-exports them
# under the names the Welcome pages have always used.

from mados_core.launcher import (
    check_updates,
    open_software,
    open_settings,
    open_terminal,
    open_files,
    open_browser
)
