# chromebook commands

# Arch Linux setup instructions
```
sudo pacman -Sy flashrom

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

# Install Alpine Linux
<img width="288" height="288" alt="image" src="https://github.com/user-attachments/assets/6cb7fd4b-3916-4c43-a7c4-506aeeb3f08f" />
