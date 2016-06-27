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

    installProgress = InstallProgress()
    cache = apt.Cache()

    packages = _getPackages(cache)

    for package in packages:
        package.mark_install()

    os.system('cls' if os.name == 'nt' else 'clear')
    sys.stdout.write("\x1b]2;Linux manager: Fetching...\x07")
    print('Start fetching...\n')

    cache.commit(install_progress=installProgress, fetch_progress=AcquireProgress())


def report():
    import apt
    from libs.aptProgress import InstallProgress

    installProgress = InstallProgress()
    cache = apt.Cache()

    installProgress.packagesReport(_getPackages(cache))
