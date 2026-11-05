import getpass
import os
import random
import shutil
import socket
from datetime import datetime

from .settings import Settings


####################################################
# Miso
#
# The MadOS cat. He watches what the PC is doing
# and comments on it. He knows this machine: its
# CPU, its memory, its uptime, its moods, and what
# o'clock it is. Serious problems get announced
# first; everything else is drawn from big pools of
# generic, system-knowing and time-aware lines, so
# he stays hard to predict.
#
# Facts come in two speeds. Cheap ones (clock,
# load, memory) are read fresh every time he
# speaks. Slow ones (update count, internet,
# package census) refresh now and then through
# refresh_facts(), called by whoever hosts him.
####################################################

class Miso:

    def __init__(self):

        self.settings = Settings()

        self.updates = None
        self.installed_packages = None
        self.online = None

        self.history = []

        # Static facts about this machine, read once
        self.hostname = self._hostname()
        self.cpu = self._cpu_model()
        self.kernel = os.uname().release
        self.user = self._user()
        self.ram_total_gb = self._ram_total_gb()
        self.version = self._mados_version()

        self.refresh_facts()

    ##################################################
    # Static facts
    ##################################################

    def _hostname(self):

        try:
            return socket.gethostname()
        except Exception:
            return None

    def _user(self):

        try:
            return getpass.getuser()
        except Exception:
            return None

    def _cpu_model(self):

        try:

            with open("/proc/cpuinfo") as f:

                for line in f:

                    if line.startswith("model name"):
                        return line.split(":", 1)[1].strip()

        except Exception:

            pass

        return None

    def _ram_total_gb(self):

        try:

            with open("/proc/meminfo") as f:

                for line in f:

                    if line.startswith("MemTotal:"):
                        return round(int(line.split()[1]) / 1024 / 1024)

        except Exception:

            pass

        return None

    def _mados_version(self):

        try:

            if os.path.exists("/etc/os-release"):

                with open("/etc/os-release") as f:

                    for line in f:

                        if line.startswith("PRETTY_NAME="):
                            return line.split("=", 1)[1].replace('"', "").strip()

        except Exception:

            pass

        return None

    ##################################################
    # Slow facts
    ##################################################

    def refresh_facts(self):

        self.updates, self.installed_packages = self._apt_facts()
        self.online = self._internet_connected()

    def _apt_facts(self):

        try:

            import apt

            cache = apt.Cache()
            cache.open(None)

            updates = 0
            installed = 0

            for pkg in cache:

                if pkg.is_upgradable:
                    updates += 1

                if pkg.is_installed:
                    installed += 1

            cache.close()

            return updates, installed

        except Exception:

            return None, None

    def _internet_connected(self):

        try:

            socket.create_connection(
                ("1.1.1.1", 53),
                timeout=2
            ).close()

            return True

        except Exception:

            return False

    ##################################################
    # Cheap facts
    ##################################################

    def _now(self):

        return datetime.now()

    def _dark(self):

        try:
            return bool(self.settings.get_dark_mode())
        except Exception:
            return False

    def _load_per_core(self):

        try:
            return os.getloadavg()[0] / (os.cpu_count() or 1)
        except Exception:
            return None

    def _busy(self):

        load = self._load_per_core()

        if load is not None and load > 1.0:
            return True

        mem = self._mem()

        if mem is not None:

            total, available = mem

            if total and available / total < 0.12:
                return True

        return False

    def _mem(self):

        try:

            total = 0
            available = 0

            with open("/proc/meminfo") as f:

                for line in f:

                    if line.startswith("MemTotal:"):
                        total = int(line.split()[1])

                    elif line.startswith("MemAvailable:"):
                        available = int(line.split()[1])

            return total, available

        except Exception:

            return None

    def _mem_used_pct(self):

        mem = self._mem()

        if mem is None:
            return None

        total, available = mem

        if not total:
            return None

        return round((total - available) / total * 100)

    def _disk(self):

        try:
            return shutil.disk_usage("/")
        except Exception:
            return None

    def _uptime_seconds(self):

        try:

            with open("/proc/uptime") as f:
                return float(f.read().split()[0])

        except Exception:

            return 0

    def _uptime_text(self):

        seconds = int(self._uptime_seconds())

        days, seconds = divmod(seconds, 86400)
        hours, seconds = divmod(seconds, 3600)
        minutes = seconds // 60

        if days:
            return f"{days}d {hours}h"

        if hours:
            return f"{hours}h {minutes}m"

        return f"{minutes}m"

    def _processes(self):

        try:
            return sum(
                1 for name in os.listdir("/proc")
                if name.isdigit()
            )
        except Exception:
            return None

    ##################################################
    # Saying selection
    ##################################################

    def _pick(self, lines):

        fresh = [
            line for line in lines
            if line not in self.history
        ] or lines

        line = random.choice(fresh)

        self.history.append(line)
        self.history = self.history[-6:]

        return line

    def mood(self):

        # Returns (emoji, line). Trouble first, in
        # order; then fresh boots; then the big
        # rotating mix of everything else.

        if self.online is False:

            return "🙀", self._pick([
                "The internet fell over. It's not just you.",
                "No internet right now. We ride it out together.",
                "The connection's gone. I've checked twice. Okay, three times.",
                "Offline. A perfect time to judge the router silently.",
                "The internet is down. I blame the router. I always blame the router.",
                "Somewhere, a router is blinking. It knows what it did."
            ])

        disk = self._disk()

        if disk is not None:

            free_gb = disk.free // (1024 ** 3)

            if free_gb < 5:

                return "🙀", self._pick([
                    "The disk is nearly full and I'm sitting on it. Help.",
                    f"Only {free_gb} GB left on the disk. Something's gotta go, and it's not me.",
                    f"{free_gb} GB free. I'm a cat, I know about squeezing into small spaces, and even I say this is tight.",
                    "The disk is gasping. I'm doing the feline equivalent of a fire alarm."
                ])

            if free_gb < 15:

                return "😿", self._pick([
                    "Storage is getting snug in here.",
                    f"{free_gb} GB free. Cozy, but I like my space.",
                    "The disk could use a clear-out one of these days. No judgement, just whiskers.",
                    f"{free_gb} GB left. I've started labelling things 'maybe delete'. Mentally. I'm helping."
                ])

        if self.updates:

            if self.updates == 1:

                return "😺", self._pick([
                    "One update waiting. Barely worth my attention. Still counts.",
                    "A single update sits in the queue, all by itself.",
                    "One update. One. I've seen bigger queues at a food bowl."
                ])

            if self.updates > 20:

                return "😺", self._pick([
                    f"{self.updates} updates. That's not a queue, that's a crowd.",
                    f"{self.updates} updates waiting. The button over there has seen things.",
                    f"{self.updates} updates deep. At this point they're basically residents."
                ])

            return "😺", self._pick([
                f"{self.updates} updates are waiting. The Check for Updates button knows what to do.",
                f"You've got {self.updates} updates queued up. No rush. Some rush.",
                f"{self.updates} updates. I counted them myself. Twice. I'm thorough.",
                f"{self.updates} updates standing by. They've been very patient. Suspiciously patient."
            ])

        if self._busy():

            return "😼", self._pick([
                "I'm running hot so you don't have to.",
                "Everything is working hard right now. Including me.",
                "The fans are earning their keep today.",
                "Big effort happening under the hood. I'm supervising from a safe, cool distance.",
                "The PC is doing that thing where it tries its best. Support it emotionally.",
                "Heavy lifting in progress. I lift nothing. I am the morale."
            ])

        now = self._now()
        hour = now.hour
        uptime = self._uptime_seconds()

        if uptime < 900:

            return "😺", self._pick([
                "Fresh boot. Everything smells new in here.",
                "Just woke up and already flawless. It's a gift.",
                "New session, clean slate, same excellent cat.",
                f"Booted {self._uptime_text()} ago. I've already inspected everything. Twice."
            ])

        ##################################################
        # The big rotating mix
        ##################################################

        lines = []
        faces = ["🐈"]

        lines += self._generic_lines()
        lines += self._system_lines()
        lines += self._time_lines(now)

        if self._dark():
            faces.append("🌙")
            lines += [
                "Dark mode and the dusk blossoms. Very us.",
                "Dark mode on. Sleek. Mysterious. A little bit me.",
                "The dusk wallpaper is up and so are my standards.",
                "Dark mode. For cats of taste and people of taste."
            ]
        else:
            lines += [
                "Light mode. Bright and pink, as is tradition.",
                "Light mode, full blossom, no notes.",
                "Everything is pink and correct.",
                "Day blossoms are out. A strong look. I approve."
            ]

        if uptime > 86400:
            lines += [
                "Over a day of uptime. This PC doesn't sleep, it waits.",
                f"Uptime: {self._uptime_text()}. We're not tired, we're experienced."
            ]
        elif uptime > 21600:
            lines += [
                "We've been up a while now. Still cute.",
                "Hours into the session and not a single complaint from me. Growth.",
                f"Session's been running {self._uptime_text()}. Comfortably settled in."
            ]

        weekday = now.weekday()

        if weekday == 0:
            lines += [
                "It's Monday. The PC and I are being brave about it.",
                "Monday again. It comes back faster than the weekend leaves.",
                "Monday. Even my whiskers are tired."
            ]
        elif weekday == 4:
            lines += [
                "Friday. The best-smelling weekday.",
                "It's Friday. The PC can feel it. I can feel it. The fans can feel it."
            ]
            if hour >= 17:
                lines.append("Friday evening. Even the fans spin happier on a Friday.")
        elif weekday >= 5:
            lines += [
                "It's the weekend. The PC knows, even if your schedule doesn't.",
                "Weekend mode. Same speed, better attitude.",
                "Weekend. The PC stretches out. Metaphorically. It has no legs. I checked."
            ]

        if hour == 0:
            lines.append("Midnight. Officially tomorrow. Don't tell the calendar I said so.")

        return random.choice(faces), self._pick(lines)

    ##################################################
    # Generic lines: the everyday cat
    ##################################################

    def _generic_lines(self):

        return [
            "Everything looks good today.",
            "All quiet. My favourite kind of shift.",
            "Have fun using MadOS. I'll be here, supervising.",
            "Systems nominal. Cat, also nominal.",
            "Nothing to report, and I mean that as a compliment.",
            "I checked everything. Twice. It's a cat thing.",
            "This machine runs well. I take partial credit, as is my right.",
            "Status: pink, stable, and unbothered.",
            "If anything breaks, you'll hear about it from me first.",
            "Another day of not being a printer. We are blessed.",
            "I've knocked nothing off the desk today. You're welcome.",
            "The vibe in this PC is immaculate, and I've inspected it personally.",
            "I've been staring at the system monitor for a while. It's called supervising.",
            "No errors today. I scared them off. You're welcome.",
            "The fans say hi. They say it loudly, but they mean well.",
            "I sit on the warm part of the PC. There is no warm part. I sit anyway.",
            "Every process fears me. As it should be.",
            "I could fix the Wi-Fi by sitting on the router, but that's a different department.",
            "My job is to watch the PC. The PC's job is to be watched. Perfect system.",
            "Somewhere there's a loading bar apologising. Not here though.",
            "I'm not asleep, I'm buffering my next inspection.",
            "Yes, I saw that notification. No, I'm not reading it to you.",
            "The bin is empty. I checked. I check everything. It's a burden.",
            "If the PC slows down, I slow down. Solidarity.",
            "Technically I'm software. Emotionally I'm the manager.",
            "I run a tight ship. The ship is a PC. The crew is also me.",
            "Everything is where I left it, because I never leave.",
            "You can tell it's a good day when I have almost nothing sarcastic to report. Almost.",
            "New line, same cat. I contain multitudes and also fur.",
            "I've decided the PC and I have an understanding. It computes, I judge.",
            "A lesser cat would nap through this shift. I nap and supervise at once.",
            "All systems purring. That one's free, the rest of my material is premium.",
            "I've licked the interface clean. Figuratively. Mostly.",
            "No news is good news, and I am excellent at no news.",
            "If I fits, I sits. I fit everywhere. It's a whole thing."
        ]

    ##################################################
    # System lines: he knows this machine
    ##################################################

    def _system_lines(self):

        lines = []

        if self.cpu:
            lines += [
                f"Running on {self.cpu}. I supervise every core personally.",
                f"{self.cpu}. Fancy silicon. I nap near it for warmth. There is no warmth. The thought counts."
            ]

        if self.ram_total_gb:
            lines += [
                f"{self.ram_total_gb} GB of memory in here, and I use almost none of it being this cute.",
                f"{self.ram_total_gb} GB of RAM. Roomy. I've claimed a corner. It's all corners."
            ]

        used = self._mem_used_pct()

        if used is not None:

            if used < 40:
                lines.append(f"Memory's at {used}%. Barely awake in there.")
            elif used < 75:
                lines.append(f"Memory's at {used}%. A healthy working sprawl.")
            else:
                lines.append(f"Memory's at {used}%. We're living large and slightly dangerously.")

        load = self._load_per_core()

        if load is not None:

            if load < 0.25:
                lines.append("The CPU is basically napping right now. Same, honestly.")
            elif load < 0.7:
                lines.append("CPU's ticking over nicely. A gentle mechanical purr.")

        disk = self._disk()

        if disk is not None:

            pct = round(disk.used / disk.total * 100)
            free_gb = disk.free // (1024 ** 3)

            lines += [
                f"The disk is {pct}% full, {free_gb} GB of breathing room. I did the maths. You're welcome.",
                f"{free_gb} GB free on the disk. Plenty of room for activities."
            ]

        procs = self._processes()

        if procs:
            lines.append(f"{procs} processes running and I supervise every single one. By name. I lie, but confidently.")

        if self.installed_packages:
            lines.append(f"{self.installed_packages} packages live in this PC. I've met most of them. The rest are shy.")

        if self.hostname:
            lines += [
                f"Hostname: {self.hostname}. Good name. Strong name. Mine's better.",
                f"They call this machine {self.hostname}. I allow it."
            ]

        if self.kernel:
            lines.append(f"Kernel {self.kernel}. I don't know what it does either, but we respect it.")

        if self.version:
            lines.append(f"{self.version}, if you're asking. I wear it well.")

        if self.user:
            lines.append(f"Logged in as {self.user}. The usual suspect.")

        lines.append(f"Current uptime: {self._uptime_text()}. I have been conscious for all of it.")

        return lines

    ##################################################
    # Time lines: what o'clock it is
    ##################################################

    def _time_lines(self, now):

        hour = now.hour
        weekday_name = now.strftime("%A")

        if hour >= 23 or hour < 5:

            return [
                "Night owl hours. I'm not judging, I'm a cat, I invented them.",
                "It's late. The PC and I are both on your schedule though.",
                "The house is quiet, the screen is glowing, we're in our element.",
                "Somewhere out there, normal computers are asleep. Not this one.",
                "It's deep in the night shift. My shift. The best shift.",
                "The moon is up, the blossoms are lit by screen glow, all is well.",
                "Late hours are when a PC and his cat get their real thinking done."
            ]

        if 5 <= hour < 7:

            return [
                "Up before the sun. One of us had to be, and it was always going to be me.",
                "Early hours. The PC boots quieter out of respect.",
                "Dawn patrol. I take it seriously. There are birds involved, conceptually."
            ]

        if 7 <= hour < 12:

            return [
                "Morning, Maddie. Systems are awake. Coffee is your department.",
                "Good morning. Everything booted, including me.",
                "Morning checks done. We're green across the board.",
                "Rise and shine. Well. You rise, I'll shine.",
                f"It's {weekday_name} morning. The PC has decided to be excellent about it.",
                "Morning. I've done my stretches. The PC has done its updates check. Balance."
            ]

        if 12 <= hour < 14:

            return [
                "Midday. Prime sunbeam hours, wasted on being a computer.",
                "Lunch hour. The PC gets crumbs of my attention. Actual crumbs are your department.",
                "High noon. The system and I regard each other with respect."
            ]

        if 14 <= hour < 17:

            return [
                "Afternoon. The long, golden middle of the shift.",
                "Afternoon slump? Not in this PC. We persevere, fabulously.",
                "The afternoon is when I do my deepest supervising. Eyes half open, fully aware.",
                f"{weekday_name} afternoon. Halfway through whatever this week is doing."
            ]

        if 17 <= hour < 20:

            return [
                "Evening. Good time for music, if anyone asks me.",
                "Evening shift. Mine. I take it very seriously, from right here.",
                "Golden hour. The screen dims, the standards don't.",
                "Evening already. The day went past like a process I forgot to watch."
            ]

        return [
            "Night's settling in. The PC glows a little softer.",
            "Evening, part two. The wind-down is a sacred ritual.",
            "Getting late ish. The PC and I are unbothered by clocks, but we notice them."
        ]
