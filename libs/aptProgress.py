from apt.progress import base
import sys

class InstallProgress(base.InstallProgress):
    """Class to report the progress of installing packages."""

    def __init__(self):
        super(InstallProgress, self).__init__()

    def start_update(self):
        """(Abstract) Start update."""
        print('\nStart apt update...\n')
        sys.stdout.write("\x1b]2;Linux apt manager: installing 0%\x07")

    def finish_update(self):
        """(Abstract) Called when update has finished."""
        sys.stdout.write("\x1b]2;Linux apt manager: finished\x07")

    def status_change(self, pkg, percent, status):
        """(Abstract) Called when the APT status changed."""
        sys.stdout.write("\x1b]2;Linux apt manager: installing {}%\x07".format(int(percent)))
