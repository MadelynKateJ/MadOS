#!/usr/bin/env python3

import gi
gi.require_version("Gtk", "3.0")

from gi.repository import Gtk

from mados_core.aptmanager import AptManager
from mados_core.installer import Installer

from widgets.updaterow import UpdateRow


class MadOSUpdate(Gtk.Window):

    def __init__(self):

        Gtk.Window.__init__(self, title="MadOS Update")

        self.set_default_size(850, 650)
        self.set_position(Gtk.WindowPosition.CENTER)

        self.manager = AptManager()
        self.installer = Installer()

        self.rows = []

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

        refresh = Gtk.Button(label="🔄 Refresh")
        refresh.connect("clicked", self.refresh)

        buttons.pack_start(
            refresh,
            True,
            True,
            0
        )

        self.install_selected = Gtk.Button(
            label="⬇ Install Selected (0)"
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

    def refresh(self, button):

        self.manager.refresh()

        updates = self.manager.get_updates()

        self.rows.clear()

        for child in self.listbox.get_children():
            self.listbox.remove(child)

        if not updates:

            self.status.set_markup(
                "<b>✔ Your system is up to date.</b>"
            )

            self.update_buttons()

            self.show_all()

            return

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

        self.update_buttons()

        self.show_all()

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

        if self.installer.install_selected(packages):

            self.status.set_markup(
                "<b>Installation started.</b>"
            )

    ##################################################

    def install_all_clicked(self, button):

        if self.installer.install_all():

            self.status.set_markup(
                "<b>Installation started.</b>"
            )


##################################################

win = MadOSUpdate()

win.connect(
    "destroy",
    Gtk.main_quit
)

win.show_all()

Gtk.main()
