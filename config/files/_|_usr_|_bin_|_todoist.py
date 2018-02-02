#!/usr/bin/env python3.6
# -*- coding: utf-8 -*-

"""
Description:
    Personal linux interface.

Usage:
    linux android apps
    linux android install

Options:
    -h --help   Extensive help message.
"""

import re
import sys

from os import path
from subprocess import Popen, PIPE, CalledProcessError
from docopt import docopt


class Shell(object):
	@staticmethod
	def _parseCmd(cmd):
		if isinstance(cmd, str):
			return cmd.split()
		return cmd

	@staticmethod
	def _calledProcessError(cmd, err):
		raise CalledProcessError(1, ' '.join(Shell._parseCmd(cmd)), output=err)

	@staticmethod
	def cmdWait(cmd, catchErr=False, output=False, workingDir=None):

		output, err = Shell.cmd(cmd, output=output, workingDir=workingDir).communicate()

		if not catchErr and err != '':
			Shell._calledProcessError(cmd, err)

		if catchErr:
			return err
		else:
			return output

	@staticmethod
	def cmd(cmd, output=False, workingDir=None):

		stdout = None if output else PIPE
		stderr = None if output else PIPE

		return Popen(Shell._parseCmd(cmd), stdout=stdout, stderr=stderr, cwd=workingDir)


class Utils(object):
	@staticmethod
	def openImage(*paths):
		return Shell.cmd(['eog', path.join(*paths)])

	@staticmethod
	def openAudioPlayer(*paths):
		Shell.cmdWait(['vlc', path.join(*paths)], catchErr=True)

	@staticmethod
	def openBrowser(url):
		Shell.cmd(['sensible-browser', url])


	apps = [
		'com.andymstone.metronome',
		'com.audible.application',
		'com.contapps.android',
		'com.evgeniysharafan.tabatatimer',
		'com.google.android.apps.adm',
		'com.urbandroid.lux',
		'hai.lior.ukaleletunerfree',
		'si.izum.mcobiss',
		'ws.appdev.android.rotation2'
	]
class Android(object):

	def __init__(self):
		Shell.cmdWait('sudo adb stop-server', catchErr=True)
		Shell.cmdWait('sudo adb start-server', catchErr=True, output=True)
		# devices = re.findall('([A-Z0-9]{2,})\s*device', Shell.cmdWait('adb devices'))
		# if len(devices) == 0:
		# 	print(' ! No devices found')
		# 	sys.exit(68)
		# else:
		# 	print(' > List of devices:')
		# 	for device in devices:
		# 		if device:
		# 			print('\t- {}'.format(device))

	def installPackages(self):
		for app in Android.apps:
			Utils.openBrowser('https://play.google.com/store/apps/details?id={}'.format(app))

	def getInstalledApps(self):
		packages = Shell.cmdWait('adb shell pm list packages -3').replace('package:', '').split()

		return filter(lambda x: not re.match(r'^\s*$', x), packages)


if __name__ == '__main__':
	args = docopt(__doc__)

	if args['android']:
		android = Android()
		if args['apps']:
			packages = android.getInstalledApps()

			installedApps = []

			print(' > User packages:')
			for package in packages:
				if package in Android.apps:
					print('\t✔ {}'.format(package))
					installedApps.append(package)
				else:
					print('\t- {}'.format(package))

			for requiredApp in Android.apps:
				if not (requiredApp in installedApps):
					print('\t✖ {}'.format(requiredApp))

		if args['install']:
			android.installPackages()
