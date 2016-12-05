#!/usr/bin/env python
"""
Description:
    Linux post installation helper.

Usage:
    make install
    make config
    make report [ --apt --pip --gem --npm --config ]

Options:
    -h --help   Extensive help message.
"""

try:
    from libs import *
    import os
    from subprocess import call
    from docopt import docopt
    from apt.cache import LockFailedException

    if __name__ == '__main__':
        args = docopt(__doc__)

        if args['install']:
            exitIfSudoIsNone()
            pre_install()
            aptInstall()
            gemInstall()
            pipInstall()
            npmInstall()
            post_install()
            print('\n > Linux installation finish.')

        elif args['report']:
            all = True
            if(args['--apt']):
                aptReport()
                all = False
            if(args['--pip']):
                pipReport()
                all = False
            if(args['--config']):
                filesReport()
                all = False
            if (args['--npm']):
                npmReport()
                all = False
            if (args['--gem']):
                gemReport()
                all = False
            if all:
                aptReport()
                pipReport()
                gemReport()
                npmReport()
                filesReport()

        elif args['config']:
            exitIfsudoIsNotNone()
            files()

except KeyError as err:
    print('ERROR: ' + err.message)

except ImportError as err:
    print('ERROR: ' + err.message)
    init()
