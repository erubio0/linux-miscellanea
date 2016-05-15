##### Lubuntu 16.04 post install custom configuration and settings

Change local repositories (ES) for the main ones and upgrade system:
```bash
sudo sed -i 's/http:\/\/es./http:\/\//g' /etc/apt/sources.list
sudo apt-get update && sudo apt-get upgrade
```

Install additional packages:
```bash
sudo apt-get install libpam-gnome-keyring cryptsetup synaptic
```
