import apt


class AptManager:

    def __init__(self):

        self.cache = apt.Cache()

    ##################################################

    def refresh(self):

        # Reload the local package cache.
        # Does NOT contact the internet or require root.

        self.cache.open()

    ##################################################

    def get_updates(self):

        updates = []

        for package in self.cache:

            if not package.is_upgradable:
                continue

            updates.append({

                "name": package.name,

                "description": package.candidate.summary,

                "installed": package.installed.version,

                "candidate": package.candidate.version

            })

        return updates

    ##################################################

    def update_count(self):

        return len(self.get_updates())

    ##################################################

    def update_names(self):

        return [

            update["name"]

            for update in self.get_updates()

        ]
