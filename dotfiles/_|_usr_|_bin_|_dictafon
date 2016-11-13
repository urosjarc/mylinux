#!/usr/bin/env python
"""
Description:
    Dictafon interface.

Usage:
    dictafon play <voice>

Options:
    -h --help   Extensive help message.
"""

from subprocess import call, PIPE
from docopt import docopt
import os

if __name__ == '__main__':
    args = docopt(__doc__)

    if args['play']:
        voicesPath = os.path.join('/media', os.environ.get('USER'), 'DVT1100/VOICE', args['<voice>'])
        voices = os.listdir(voicesPath)

        for file in voices:
            filePath = os.path.join(voicesPath, file)
            print(filePath)
            call('audacity ' + filePath + ' > /dev/null 2>&1', shell=True)
