# Workstation Ubuntu Linux 21.04

## Todo

* i3barista
    * install via fork
    * install fonts (xref: https://barista.run/pango/icons#default-installation)
* intellij
    * download tarball from idea
    * extract and move to /opt
    * run /opt/idea-*/bin/idea.sh
    * Tools > Create Desktop Entry
    * plugins
        * go
        * kubernetes
* go
    * download latest go tarball
    * extract into /usr/local/go
    * in .zshrc: export PATH=$PATH:/usr/local/go/bin
* fzf-tab
    * git clone https://github.com/Aloxaf/fzf-tab.git

## Troubleshooting

* blank screen on first boot after fresh install
    * boot with advanced settings
        * recovery mode
        * network
        * root
    * install nvidia drivers
        * ubuntu-drivers autoinstall
