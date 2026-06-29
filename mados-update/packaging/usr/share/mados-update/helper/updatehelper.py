#!/usr/bin/env python3

import sys
import apt


def install_packages(package_names):

    cache = apt.Cache()

    cache.open()

    for package in package_names:

        if package in cache:

            cache[package].mark_upgrade()

    cache.commit()


def install_all():

    cache = apt.Cache()

    cache.open()

    for package in cache:

        if package.is_upgradable:

            package.mark_upgrade()

    cache.commit()


########################################################

if __name__ == "__main__":

    if len(sys.argv) < 2:

        sys.exit(1)

    command = sys.argv[1]

    if command == "all":

        install_all()

    elif command == "selected":

        install_packages(sys.argv[2:])
