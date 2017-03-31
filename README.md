# **Bash script to install and configure a CentOS 7 machine.**

### **About**

Install and configure the following components :
- epel repository
- transmisison server
- nginx webserver
- samba
- ftp server
- sshd config
- wget
- iptables rules
- plexmediaserver.rpm
- .vimrc file
- cronjobs

It installs the services mentioned using custom configuration files. If you don't supply any just comment out lines `394` and `395` in `main.sh`.

---

### **Usage**

Custom colour codes are defined in `configs/colors.ini` file. You can easily add more or modify the existing ones. Default and custom file paths are defined in `configs/file_paths.ini`. Modify them to your liking.
Store your custom application files in `app_files` directory. I have not provided any files there.

Be sure to run `yum update` before calling the script.

---
### **Enjoy**
