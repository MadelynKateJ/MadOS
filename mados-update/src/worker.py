import threading


class Worker(threading.Thread):

    def __init__(self, target, finished):

        super().__init__()

        self.target = target
        self.finished = finished

    ##################################################

    def run(self):

        result = self.target()

        self.finished(result)
