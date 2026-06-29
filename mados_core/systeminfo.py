import os
import shutil
import socket
import subprocess


def internet_connected():
    try:
        socket.create_connection(("1.1.1.1", 53), timeout=2)
        return True
    except:
        return False


def command_exists(command):
    return shutil.which(command) is not None


def get_memory():
    total = 0
    available = 0

    with open("/proc/meminfo") as f:
        for line in f:
            if line.startswith("MemTotal:"):
                total = int(line.split()[1]) // 1024
            elif line.startswith("MemAvailable:"):
                available = int(line.split()[1]) // 1024

    used = total - available

    return f"{used/1024:.1f} / {total/1024:.1f} GB"


def get_disk():
    usage = shutil.disk_usage("/")

    free = usage.free // (1024**3)

    return f"{free} GB Free"


def get_cpu():
    with open("/proc/cpuinfo") as f:
        for line in f:
            if line.startswith("model name"):
                return line.split(":")[1].strip()

    return "Unknown CPU"


def steam_installed():
    return command_exists("steam")


def nvidia_installed():
    return command_exists("nvidia-smi")


def get_mados_version():
    if os.path.exists("/etc/os-release"):
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("PRETTY_NAME="):
                    return line.split("=")[1].replace('"', "").strip()

    return "MadOS"
