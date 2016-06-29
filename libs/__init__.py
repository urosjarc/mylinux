def _getAptPackages(cache):
    packages = []

    with open('./config/packages/apt') as file:
        packagesNames = file.readlines()

        for packageName in packagesNames:
            packages.append(cache[packageName.strip()])

    return packages

def _getPipPackages():
    packages = []

    with open('./config/packages/pip') as file:
        packagesNames = file.readlines()

        for packageName in packagesNames:
            packages.append(packageName.strip())

    return packages

def _getNpmPackages():
    packages = []

    with open('./config/packages/npm') as file:
        packagesNames = file.readlines()

        for packageName in packagesNames:
            packages.append(packageName.strip())

    return packages

def aptInstall():
    import apt
    from apt.progress.text import AcquireProgress
    from libs.aptProgress import InstallProgress
    import sys, os

    if os.getenv("SUDO_USER") is None:
        print('Run script with sudo command!')
        exit()

    installProgress = InstallProgress()
    cache = apt.Cache()

    packages = _getAptPackages(cache)

    for package in packages:
        package.mark_install()

    os.system('cls' if os.name == 'nt' else 'clear')
    sys.stdout.write("\x1b]2;Linux apt manager: fetching\x07")
    print('Start apt fetching...\n')

    cache.commit(install_progress=installProgress, fetch_progress=AcquireProgress())

def pipInstall():
    import pip,sys

    sys.stdout.write("\x1b]2;Linux pip manager: installing\x07")
    print('\nStart pip update...\n')

    for packageName in _getPipPackages():
        pip.main(['install', packageName])

    sys.stdout.write("\x1b]2;Linux pip manager: finished\x07")

def npmInstall():
    from subprocess import call
    import sys

    sys.stdout.write("\x1b]2;Linux npm manager: installing\x07")
    print('\nStart npm update...\n')

    call(('sudo npm install -g ' + ' '.join(_getNpmPackages())).split())
    sys.stdout.write("\x1b]2;Linux npm manager: finished\x07")

def aptReport():
    import apt
    from tabulate import tabulate
    from libs.aptProgress import InstallProgress

    cache = apt.Cache()

    print('\nApt report:\n')
    table = []
    for package in _getAptPackages(cache):
        table.append([
            package.section,
            package.name,
            package.candidate.version,
            str(package.is_installed),
            str(package.is_now_broken)
        ])

    print(tabulate(table, headers=["Section", "Package", "Version", 'Installed', 'Broken'], tablefmt='fancy_grid'))

def pipReport():
    import importlib, subprocess,os
    from tabulate import tabulate

    print('\nPip report:\n')
    table = []
    for packageName in _getPipPackages():
        output = subprocess.Popen(('pip show ' + packageName).split(), stdout=subprocess.PIPE).communicate()[0]
        if output=='' or output.isspace():
            version = 'None'
        else:
            version = output.split('\n')[3].split()[1]
        try:
            globals()[packageName] = importlib.import_module(packageName)
            table.append([packageName,version,'True'])
        except ImportError:
            table.append([packageName,version,'False'])
    print(tabulate(table, headers=["Package","Version","Can import"], tablefmt='fancy_grid'))

def configReport():
    from os.path import join
    import os
    import filecmp
    from tabulate import tabulate

    print('\nConfig report:\n')

    dotfiles = os.path.abspath('./dotfiles')
    table = []
    # traverse root directory, and list directories as dirs and files as files
    for root, dirs, files in os.walk(dotfiles):
        for file in files:
            fileSrc = join(dotfiles,file)
            filePath = file.replace('_|_', '/').replace('~',join(os.path.expanduser("~"),'Desktop/linux/test'))
            if(os.path.exists(filePath)):
                table.append([
                    file,
                    file.replace('_|_', '/'),
                    'True',
                    str(filecmp.cmp(fileSrc,filePath))
                ])
            else:
                table.append([
                    file,
                    file.replace('_|_', '/'),
                    'False',
                    'False'
                ])

    print(tabulate(table,headers=["Source", "Destination","Exists","Equal"], tablefmt='fancy_grid'))

def npmReport():
    import subprocess
    from tabulate import tabulate

    print('\nNpm report:\n')
    output = subprocess.Popen(('npm list -g --depth=0').split(), stdout=subprocess.PIPE).communicate()[0]
    installedPacs = output.split()[2::2]
    table = []
    for package in _getNpmPackages():
        version = None
        for installedPac in installedPacs:
            if package.strip()==installedPac.split('@')[0]:
                version = installedPac.split('@')[1]
        table.append([package,str(version)])
    print(tabulate(table,headers=['Package','Version'],tablefmt='fancy_grid'))

def config():
    import shutil,sys
    from os.path import join
    import os

    sys.stdout.write("\x1b]2;Linux config manager: starting\x07")
    print('\nStart config update...\n')

    dotfiles = os.path.abspath('./dotfiles')
    mode = 0700 #Owner can r,w,x

    if os.getenv("SUDO_USER") is not None:
        print('Run script without sudo command.')
        print(' - {} should not have locked access to config files!'.format(os.getenv('SUDO_USER')))
        print(' - chmod(root,{})'.format(oct(mode)))
        exit()

    # traverse root directory, and list directories as dirs and files as files
    for root, dirs, files in os.walk(dotfiles):
        for file in files:
            fileSrc = join(dotfiles,file)
            filePath = file.replace('_|_', '/').replace('~',join(os.path.expanduser("~"),'Desktop/linux/test'))
            fileDir = '/'.join(filePath.split('/')[:-1])
            if not os.path.exists(fileDir):
                try:
                    original_umask = os.umask(0)
                    os.makedirs(fileDir,mode)
                finally:
                    os.umask(original_umask)

            shutil.copyfile(fileSrc,filePath)
            os.chmod(filePath,mode)
            print(filePath)

    sys.stdout.write("\x1b]2;Linux config manager: finished\x07")

def init():
    from subprocess import call

    if 'y' == raw_input('Do you want setup linux? (y/n): '):
        call("sh ./config/scripts/init.sh".split())