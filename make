#!/usr/bin/env python3
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
	import shutil
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
			if (args['--apt']):
				aptReport()
				all = False
			if (args['--pip']):
				pipReport()
				all = False
			if (args['--config']):
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
			copy('background', '~/.i3/background')
			copy('layouts', '~/.i3/layouts')

except KeyError as err:
	print('ERROR: ' + str(err))

except ImportError as err:
	print('ERROR: ' + str(err))
	init()
