##### Ubuntu GNOME 16.04 post install custom configuration and settings

Change local repositories (ES) for the main ones and upgrade system:
```bash
sudo sed -i 's/http:\/\/es./http:\/\//g' /etc/apt/sources.list
sudo apt-get update && sudo apt-get upgrade
```

Install additional packages:
```bash
sudo apt-get install cryptsetup synaptic
```

Import GNOME settings (can be easily exported using `dconf dump / > custom-values.dconf`):
```bash
dconf load / < custom-values.dconf
```

Install Arc theme (https://github.com/horst3180/Arc-theme), and enable for GTK+ only:
```bash
wget -qO - http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | sudo apt-key add -
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list"
sudo apt-get update
sudo apt-get install arc-theme
gsettings set org.gnome.desktop.interface gtk-theme 'Arc'
```
Font size

* Gnome
  * Use tweak tool
* Firefox
  * about:config -> layout.css.devPixelsPerPx


