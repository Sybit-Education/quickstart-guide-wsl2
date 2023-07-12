# Sybit Quick Start Guide


## Requirements

[You must be running Windows 10, version 2004 and later (build 19041 and later), or Windows 11 to use the following commands. If you are using earlier versions, see the information on the manual installation page.](https://learn.microsoft.com/de-de/windows/wsl/install-manual)

---

## Installing the WSL-2

Open Windows Commandline with administrative privileges, and run the following:

```shell
wsl --install
```

This command activates the features required to run WSL and installs the Ubuntu distribution of Linux

---

## Configure your WSL-2

After the installation:

- Open Ubuntu via the menu context
- As UNIX username i recommend your company abbreviation
- Set a secure password

Update your distribution:

```shell
sudo apt-get update
```

```shell
sudo apt-get dist-upgrade
```

Create project folder:

```shell
mkdir projects
```

Hide last login time:

```shell
touch .hushlogin
```

Install Unzip:
```shell
sudo apt-get install unzip zip
```

---

### Install Java (SDKMAN with OpenJDK)

Download and install [SDKMAN](https://sdkman.io/):

```shell
curl -s "https://get.sdkman.io" | bash
```

Next, open a new terminal or enter:
```shell
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

Install OpenJDK:

```shell
 sdk install java 17.0.7-ms
```

---

### Install Node.js (NVM with Latest LTS Version)

Download and install [NVM](https://github.com/nvm-sh/nvm):

```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
```

Enter to complete:
```shell
source "$HOME/.nvm/nvm.sh"
```

Install Latest Node.js Version:

```shell
 nvm install --lts
```

---

### Configure GIT

Replace the placerholder below and paste it in your commandline:

```shell
git config --global user.name "Max Mustermann"
```

```shell
git config --global user.email "Max.Mustermann@CompanyDomain.de"
```

---

## Useful tips

### Make your life easier with aliases

Enter following command in your commandline:

```shell
nano .bashrc
```

Copy, paste and save the following lines:

```shell
alias update="sudo apt update && sudo apt -y upgrade"
alias build="sh gradlew build"
alias cleanBuild="sh gradlew clean build"
```

Enter following command in your commandline or open a new tab:

```shell
source .bashrc
```

---

### Copy files from Windows directly into the WSL:

```shell
cp -R /mnt/c/Users/Username/pathFromWindows ~/wishedWSLDestination
```

---

### Change your Node.js Version

Run the command to see the list of available versions:

```shell
nvm list-remote
```

Run the command to install your preferred version:

```shell
nvm install xx.x.x
```

Run the command to set your new default:

```shell
nvm alias default xx.x.x
```

---

### Change your Java Version

Run the command to see the list of available versions:

```shell
sudo update-alternatives --config java
```

--- 

### Update your WSL-2

Open Windows Commandline with administrative privileges, and run the following:

```shell
wsl --update
```
