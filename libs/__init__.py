def _getPackages(cache):
    packages = []

    with open('packages') as file:
        packagesNames = file.readlines()

        for packageName in packagesNames:
            packages.append(cache[packageName.strip()])

    return packages

def install():
    import apt
    from apt.progress.text import AcquireProgress
    from libs.aptProgress import InstallProgress
    import sys, os

    if os.getenv("SUDO_USER") is None:
        print('Run script with sudo command!')
        exit()

    installProgress = InstallProgress()
    cache = apt.Cache()

    packages = _getPackages(cache)

    for package in packages:
        package.mark_install()

    os.system('cls' if os.name == 'nt' else 'clear')
    sys.stdout.write("\x1b]2;Linux manager: fetching\x07")
    print('Start fetching...\n')

    cache.commit(install_progress=installProgress, fetch_progress=AcquireProgress())

def report():
    import apt
    from tabulate import tabulate
    from libs.aptProgress import InstallProgress

    cache = apt.Cache()

    print('Package report:')
    table = []
    for package in _getPackages(cache):
        table.append([
            package.section,
            package.name,
            package.candidate.version,
            str(package.is_installed),
            str(package.is_now_broken)
        ])

    print(tabulate(table, headers=["Section", "Package", "Version", 'Installed', 'Broken'], tablefmt='fancy_grid'))

def config():
    import shutil
    from os.path import join
    import os

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
            filePath = file.replace('_|_', '/').replace('~',os.path.expanduser("~"))
            fileDir = '/'.join(filePath.split('/')[:-1])
            if not os.path.exists(fileDir):
                try:
                    original_umask = os.umask(0)
                    os.makedirs(fileDir,mode)
                finally:
                    os.umask(original_umask)

            shutil.copyfile(fileSrc,filePath)
            os.chmod(filePath,mode)