# All my packages

This repository is for personal use only.
It contains helper scripts tailored for my usage.

Start by enabling ssh?

```
sudo apt install openssh-server
```

Launch the start script:
```
wget https://raw.githubusercontent.com/jehon/packages/master/start; chmod +x start; less start; sudo ./start
```

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
