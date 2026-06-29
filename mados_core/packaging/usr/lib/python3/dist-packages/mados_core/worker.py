import threading
from gi.repository import GLib


class Worker(threading.Thread):

    def __init__(self, target, finished=None):

        super().__init__(daemon=True)

        self.target = target
        self.finished = finished

    ##################################################

    def run(self):

        success = False

        try:

            success = self.target()

        except Exception as e:

            print(e)

        if self.finished:

            GLib.idle_add(
                self.finished,
                success
            )
