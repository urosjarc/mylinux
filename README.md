![Linux](https://monovm.com/images/unzip-centos.png)
==========
Linux post installation helper for install and config. your custom linux system.

## Tell me more!

After installing linux os you want to setup the programms that you will
be using (window manager, terminal, vim, etc...). You can install and
config. those apps by hand but its pain in the ass. You can also try to
over do it with [FAI (Fully Automatic Installation)](http://fai-project.org/)!
I have try and fail, so I made my own "post installation helper for linux",
to save and automate initial setup for my pimp-ed out linux system.

## How it works?

**linux** is writen in python (default programming lang. for linux), so
it should work out of the box for every linux os.

In the directory `./config/packages` you can define what packages
you want for **linux** to install. For now **linux** support only apt, npm, and pip
package managers. For example, if you want to install `chromium-browser`
you will add line `chromium-browser` in `./config/packages/apt` etc...

All config files for your system is placed in `./dotfiles` aka (hiden files)
directory. In this directory should be only files with the names that
represents where you want to copy and name file. For example, if you
want to place file `.vimrc` to the path `~/.vimrc` you will copy all `.virmc`
data to file with the name `~_|_.vimrc` and place it in `./dotfiles` directory.
Be aware that **linux** will replace all "**\_|\_**" with "**/**" !
So if you want place `.vimrc` file in directory `/home/user/Desktop`,
you will name the file in `./dotfiles` as `_|_home_|_user_|_Desktop_|_.vimrc`,
and **linux** will create all directories in path if they don't exist and
copy file to `/home/user/Desktop/.vimrc`.

Before and after installation and configuration you will want
to setup for example apt repository or define default browser etc... 
You can define all those things in scripts `post_install.sh` and `pre_install.sh`
that are located in `./config/scripts` directory. The script with the
name `init.sh` is reserved for installing **linux** dependencies... 

## OK, I let's try it out!

Hold your horses, and follow steps:

1. Open terminal.
2. Exec: `wget https://github.com/urosjarc/linux/archive/master.zip`
3. Exec: `unzip master.zip`
4. Exec: `cd linux-master`
5. Exec: `./linux`
6. Say yes and all **linux** dependencies will be installed...

**linux** interface:
```
    ./linux install
    ./linux config
    ./linux report [ --apt --pip --npm --config ]
```

## But what if **linux** fail to setup something?

For that purpouse **linux** has advance report system. After installation
youst execute `./linux report` and you will see if every thing is setup
and ready to be used.

Example of `./linux report --config`:

```
Config report:

╒═══════════════════════════════════╤═════════════════════════════╤══════════╤═════════╕
│ Source                            │ Destination                 │ Exists   │ Equal   │
╞═══════════════════════════════════╪═════════════════════════════╪══════════╪═════════╡
│ _|_usr_|_bin_|_pycharm            │ /usr/bin/pycharm            │ True     │ True    │
├───────────────────────────────────┼─────────────────────────────┼──────────┼─────────┤
│ ~_|_.gitconfig                    │ ~/.gitconfig                │ True     │ True    │
├───────────────────────────────────┼─────────────────────────────┼──────────┼─────────┤
│ _|_usr_|_bin_|_intellij           │ /usr/bin/intellij           │ True     │ True    │
├───────────────────────────────────┼─────────────────────────────┼──────────┼─────────┤
│ ~_|_.zshrc                        │ ~/.zshrc                    │ True     │ True    │
├───────────────────────────────────┼─────────────────────────────┼──────────┼─────────┤
│ ~_|_.config_|_ranger_|_rc.conf    │ ~/.config/ranger/rc.conf    │ True     │ True    │
├───────────────────────────────────┼─────────────────────────────┼──────────┼─────────┤
│ ~_|_.config_|_terminator_|_config │ ~/.config/terminator/config │ True     │ True    │
├───────────────────────────────────┼─────────────────────────────┼──────────┼─────────┤
│ _|_usr_|_bin_|_webstorm           │ /usr/bin/webstorm           │ True     │ True    │
├───────────────────────────────────┼─────────────────────────────┼──────────┼─────────┤
│ ~_|_.i3_|_config                  │ ~/.i3/config                │ True     │ True    │
├───────────────────────────────────┼─────────────────────────────┼──────────┼─────────┤
│ ~_|_.i3_|_i3status.conf           │ ~/.i3/i3status.conf         │ True     │ True    │
├───────────────────────────────────┼─────────────────────────────┼──────────┼─────────┤
│ ~_|_.ideavimrc                    │ ~/.ideavimrc                │ False    │ False   │
╘═══════════════════════════════════╧═════════════════════════════╧══════════╧═════════╛

```

Example of `./linux report --apt`:

```
Apt report:

╒═══════════════════╤═══════════════════════════╤═════════════════════════════════════╤═════════════╤══════════╕
│ Section           │ Package                   │ Version                             │ Installed   │ Broken   │
╞═══════════════════╪═══════════════════════════╪═════════════════════════════════════╪═════════════╪══════════╡
│ admin             │ aptitude                  │ 0.7.4-2ubuntu2                      │ True        │ False    │
├───────────────────┼───────────────────────────┼─────────────────────────────────────┼─────────────┼──────────┤
│ devel             │ build-essential           │ 12.1ubuntu2                         │ True        │ False    │
├───────────────────┼───────────────────────────┼─────────────────────────────────────┼─────────────┼──────────┤
│ multiverse/web    │ pepperflashplugin-nonfree │ 1.8.2ubuntu1                        │ True        │ False    │
├───────────────────┼───────────────────────────┼─────────────────────────────────────┼─────────────┼──────────┤
│ universe/x11      │ i3                        │ 4.11-1                              │ True        │ False    │
├───────────────────┼───────────────────────────┼─────────────────────────────────────┼─────────────┼──────────┤
│ shells            │ zsh                       │ 5.1.1-1ubuntu2                      │ True        │ False    │
├───────────────────┼───────────────────────────┼─────────────────────────────────────┼─────────────┼──────────┤
│ universe/misc     │ terminator                │ 0.98-1                              │ True        │ False    │
├───────────────────┼───────────────────────────┼─────────────────────────────────────┼─────────────┼──────────┤
│ universe/sound    │ alsamixergui              │ 0.9.0rc2-1-9.1                      │ True        │ False    │
├───────────────────┼───────────────────────────┼─────────────────────────────────────┼─────────────┼──────────┤
│ gnome             │ gparted                   │ 0.25.0-1                            │ True        │ False    │
╘═══════════════════╧═══════════════════════════╧═════════════════════════════════════╧═════════════╧══════════╛
```

## Is this all?

I must to tell you one more thing! While the installation process will
be in process you can follow additional information in the terminal title
section. This project doesn't have licence so do what ever you want with
it. I think this is all for now!

P.S.(author): Have fun as much as I did with this project!

