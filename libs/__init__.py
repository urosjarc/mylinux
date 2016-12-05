_mode = 0700 #Owner can r,w,x

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

def _getGemPackages():
    packages = []

    with open('./config/packages/gem') as file:
        packagesNames = file.readlines()

        for packageName in packagesNames:
            packages.append(packageName.strip())

    return packages

def exitIfSudoIsNone():
    import os
    if os.getenv("SUDO_USER") is None:
        print('Run script with sudo command!')
        exit()

def aptInstall():
    import apt
    from apt.progress.text import AcquireProgress
    from libs.aptProgress import InstallProgress
    import sys, os

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

def gemInstall():
    from subprocess import call
    import sys

    sys.stdout.write("\x1b]2;Linux gem manager: installing\x07")
    print('\nStart gem update...\n')

    call(('sudo gem install ' + ' '.join(_getGemPackages())).split())
    sys.stdout.write("\x1b]2;Linux gem manager: finished\x07")

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
    import importlib, subprocess
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

def filesReport():
    from os.path import join
    import os
    import filecmp
    from tabulate import tabulate

    print('\nConfig report:\n')

    dotfiles = os.path.abspath('./config/dotfiles')
    table = []
    # traverse root directory, and list directories as dirs and files as files
    for root, dirs, files in os.walk(dotfiles):
        for file in files:
            fileSrc = join(dotfiles,file)
            filePath = file.replace('_|_', '/').replace('~',os.path.expanduser("~"))
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

def gemReport():
    import subprocess
    from tabulate import tabulate

    print('\nGem report:\n')
    output = subprocess.Popen(('gem list').split(), stdout=subprocess.PIPE).communicate()[0]
    installedPacs = output.split('\n')
    table = []
    for package in _getGemPackages():
        version = None
        for installedPac in installedPacs:
            if package.strip()==installedPac.split(' ')[0]:
                version = installedPac.split(' ')[1].replace('(','').replace(')','')
        table.append([package,str(version)])
    print(tabulate(table,headers=['Package','Version'],tablefmt='fancy_grid'))

def files():
    import shutil,sys
    from subprocess import call
    from os.path import join
    import os

    sys.stdout.write("\x1b]2;Linux files manager: starting\x07")
    print('\nStart files update...\n')

    dotfiles = os.path.abspath('./config/files')
    sudoFiles = []

    # traverse root directory, and list directories as dirs and files as files
    for root, dirs, files in os.walk(dotfiles):
        for file in files:
            fileSrc = join(dotfiles,file)
            filePath = file.replace('_|_', '/').replace('~',os.path.expanduser("~"))
            fileDir = '/'.join(filePath.split('/')[:-1])
            if not os.path.exists(fileDir):
                try:
                    original_umask = os.umask(0)
                    os.makedirs(fileDir,_mode)
                finally:
                    os.umask(original_umask)

	    try:
		shutil.copyfile(fileSrc,filePath)
		os.chmod(filePath,_mode)
		print(filePath)
	    except IOError:
		sudoFiles.append([fileSrc,filePath])
	    except OSError:
		sudoFiles.append([fileSrc,filePath])

    for sudoFile in sudoFiles:
	call('sudo cp {} {}'.format(sudoFile[0],sudoFile[1]).split())
	call('sudo chmod {} {}'.format("755",sudoFile[1]).split())
	print(sudoFile[1])

    sys.stdout.write("\x1b]2;Linux files manager: finished\x07")

def init():
    from subprocess import call
    import sys

    sys.stdout.write("\x1b]2;Linux manager: init\x07")
    print('\nStart init...\n')

    if 'y' == raw_input('Do you want setup linux? (y/n): '):
        call("sh ./config/scripts/init.sh".split())

def pre_install():
    from subprocess import call
    import sys

    sys.stdout.write("\x1b]2;Linux manager: pre_install\x07")
    print('\nStart pre. install...\n')

    call("sh ./config/scripts/pre_install.sh".split())

def post_install():
    from subprocess import call
    import sys

    sys.stdout.write("\x1b]2;Linux manager: post_install\x07")
    print('\nStart post. install...\n')

    call("sh ./config/scripts/post_install.sh".split())

def exitIfsudoIsNotNone():
    import os

    if os.getenv("SUDO_USER") is not None:
        print('Run script with sudo command.')
        print(' - "{}" should not have locked access to config files!'.format(os.getenv('USER')))
        print(' - chmod(root,{})'.format(oct(_mode)))
        exit()
