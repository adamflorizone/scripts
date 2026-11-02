# chromebook commands

# Arch Linux permissions setup instructions
sudo pacman -Sy flashrom

```
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666"' | sudo tee /etc/udev/rules.d/99-raiden-debug.rules
sudo udevadm control --reload-rules
sudo udevadm trigger

sudo usermod -a -G tty $USER
sudo usermod -aG uucp $USER
```


## ESC + Refresh terminal

### 1. username
![chromebook.username](./chromebook.username.png)

### 2. script
![chromebook](./chromebook.png)
