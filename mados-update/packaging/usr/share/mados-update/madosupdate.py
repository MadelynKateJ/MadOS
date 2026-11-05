#!/usr/bin/env python3

import threading

import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk, GLib

from mados_core.aptmanager import AptManager
from mados_core.installer import Installer

from widgets.updaterow import UpdateRow


class MadOSUpdate(Gtk.Window):

    def __init__(self):

        Gtk.Window.__init__(self, title="MadOS Update")

        # Follow the MadOS accent like the other apps
        from mados_ui.style import MadStyleManager

        MadStyleManager.load()

        self.set_default_size(850, 650)
        self.set_position(Gtk.WindowPosition.CENTER)

        self.manager = AptManager()
        self.installer = Installer()

        self.rows = []
        self.busy = False

        ##################################################

        root = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=15
        )

        root.set_margin_top(20)
        root.set_margin_bottom(20)
        root.set_margin_start(20)
        root.set_margin_end(20)

        self.add(root)

        ##################################################

        title = Gtk.Label()

        title.set_markup(
            "<span size='24000' weight='bold'>🌸 MadOS Update</span>"
        )

        title.set_xalign(0)

        root.pack_start(title, False, False, 0)

        ##################################################

        self.status = Gtk.Label()

        self.status.set_xalign(0)

        self.status.set_markup(
            "<b>Press Refresh to check for updates.</b>"
        )

        root.pack_start(self.status, False, False, 0)

        ##################################################

        toolbar = Gtk.Box(spacing=10)

        root.pack_start(toolbar, False, False, 0)

        self.select_all = Gtk.CheckButton(label="Select All")

        self.select_all.connect(
            "toggled",
            self.toggle_all
        )

        toolbar.pack_start(
            self.select_all,
            False,
            False,
            0
        )

        self.selected_label = Gtk.Label(label="Selected: 0")

        toolbar.pack_end(
            self.selected_label,
            False,
            False,
            0
        )

        ##################################################

        scroll = Gtk.ScrolledWindow()

        scroll.set_vexpand(True)

        root.pack_start(
            scroll,
            True,
            True,
            0
        )

        self.listbox = Gtk.ListBox()

        self.listbox.set_selection_mode(
            Gtk.SelectionMode.NONE
        )

        scroll.add(self.listbox)

        ##################################################

        buttons = Gtk.Box(spacing=10)

        root.pack_end(buttons, False, False, 0)

        self.refresh_button = Gtk.Button(label="🔄 Refresh")
        self.refresh_button.get_style_context().add_class(
            "mad-button"
        )
        self.refresh_button.connect("clicked", self.refresh)

        buttons.pack_start(
            self.refresh_button,
            True,
            True,
            0
        )

        self.install_selected = Gtk.Button(
            label="⬇ Install Selected (0)"
        )

        self.install_selected.get_style_context().add_class(
            "mad-button"
        )

        self.install_selected.connect(
            "clicked",
            self.install_selected_clicked
        )

        self.install_selected.set_sensitive(False)

        buttons.pack_start(
            self.install_selected,
            True,
            True,
            0
        )

        self.install_all = Gtk.Button(
            label="⬇ Install All"
        )

        self.install_all.get_style_context().add_class(
            "mad-button"
        )

        self.install_all.connect(
            "clicked",
            self.install_all_clicked
        )

        self.install_all.set_sensitive(False)

        buttons.pack_start(
            self.install_all,
            True,
            True,
            0
        )

    ##################################################

    def refresh(self, button=None):

        # Refresh means: fetch fresh package lists first (this is
        # the part that needs the password prompt), then re-read
        # the cache. All of it runs off the UI thread so the
        # window never freezes.
        self._start_check(fetch=True)

    ##################################################

    def _start_check(self, fetch):

        if self.busy:
            return

        self.set_busy(
            True,
            "🔄 Checking for updates…"
        )

        def work():

            if fetch:

                # Best effort: if the password prompt is
                # cancelled the lists stay stale, but the
                # check still completes with what we have.
                self.installer.update_package_lists()

            self.manager.refresh()

            updates = self.manager.get_updates()

            GLib.idle_add(
                self._show_updates,
                updates
            )

        threading.Thread(
            target=work,
            daemon=True
        ).start()

    ##################################################

    def _show_updates(self, updates):

        self.rows.clear()

        for child in self.listbox.get_children():
            self.listbox.remove(child)

        if not updates:

            self.status.set_markup(
                "<b>✔ Your system is up to date.</b>"
            )

            self.set_busy(False)

            self.update_buttons()

            self.show_all()

            return False

        self.status.set_markup(
            f"<b>{len(updates)} updates available.</b>"
        )

        for package in updates:

            row = UpdateRow(package)

            row.checkbox.connect(
                "toggled",
                self.row_toggled
            )

            self.rows.append(row)

            self.listbox.add(row)

        self.set_busy(False)

        self.update_buttons()

        self.show_all()

        return False

    ##################################################

    def set_busy(self, busy, text=None):

        self.busy = busy

        self.refresh_button.set_sensitive(not busy)

        self.select_all.set_sensitive(not busy)

        if busy:

            self.install_selected.set_sensitive(False)

            self.install_all.set_sensitive(False)

            if text:

                self.status.set_markup(
                    f"<b>{text}</b>"
                )

        else:

            self.update_buttons()

    ##################################################

    def row_toggled(self, widget):

        self.update_buttons()

    ##################################################

    def toggle_all(self, widget):

        state = widget.get_active()

        for row in self.rows:

            row.set_selected(state)

        self.update_buttons()

    ##################################################

    def update_buttons(self):

        total = len(self.rows)

        selected = sum(
            row.is_selected()
            for row in self.rows
        )

        self.selected_label.set_text(
            f"Selected: {selected}"
        )

        self.install_selected.set_label(
            f"⬇ Install Selected ({selected})"
        )

        self.install_all.set_label(
            f"⬇ Install All ({total})"
        )

        self.install_selected.set_sensitive(
            selected > 0
        )

        self.install_all.set_sensitive(
            total > 0
        )

    ##################################################

    def install_selected_clicked(self, button):

        packages = []

        for row in self.rows:

            if row.is_selected():
                packages.append(row.package["name"])

        if not packages:
            return

        self._start_install(
            lambda: self.installer.install_selected(packages)
        )

    ##################################################

    def install_all_clicked(self, button):

        self._start_install(self.installer.install_all)

    ##################################################

    def _start_install(self, job):

        if self.busy:
            return

        self.set_busy(
            True,
            "⬇ Installing updates… (password prompt may appear)"
        )

        def work():

            ok = job()

            GLib.idle_add(
                self._install_done,
                ok
            )

        threading.Thread(
            target=work,
            daemon=True
        ).start()

    ##################################################

    def _install_done(self, ok):

        if not ok:

            self.set_busy(False)

            reason = GLib.markup_escape_text(
                self.installer.last_summary()
            )

            self.status.set_markup(
                "<b>✖ Installation failed:</b> " + reason
            )

            return False

        # Success: re-read the cache so the list (and the final
        # status line) reflects reality.
        self.busy = False

        self._start_check(fetch=False)

        return False


##################################################

win = MadOSUpdate()

win.connect(
    "destroy",
    Gtk.main_quit
)

win.show_all()

Gtk.main()
