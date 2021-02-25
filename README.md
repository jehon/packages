# All my packages

This repository is for personal use only.
It contains helper scripts tailored for my usage.

wget https://raw.githubusercontent.com/jehon/packages/master/start; chmod +x start; less start; ./start

## Ubuntu

### Switch between windows of the current workspace

dconf write /org/gnome/shell/app-switcher/current-workspace-only 'true'

### shuttle pro
-> removable element?

# VSCode config

Shellcheck:
    "shellcheck.customArgs": [
        "-x"
    ],
    "shellcheck.useWorkspaceRootAsCwd": false // default
