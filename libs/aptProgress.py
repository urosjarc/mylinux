from apt.progress import base
import sys

class InstallProgress(base.InstallProgress):
    """Class to report the progress of installing packages."""

    def __init__(self):
        super(InstallProgress, self).__init__()

    def start_update(self):
        """(Abstract) Start update."""
        print('\nStart update...\n')
        sys.stdout.write("\x1b]2;Linux manager: installing 0%\x07")

    def finish_update(self):
        """(Abstract) Called when update has finished."""
        print('\r\nFinish update...\n')
        sys.stdout.write("\x1b]2;Linux manager: finished\x07")

    def status_change(self, pkg, percent, status):
        """(Abstract) Called when the APT status changed."""
        sys.stdout.write("\x1b]2;Linux manager: installing {}%\x07".format(int(percent)))
