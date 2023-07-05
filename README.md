# WSL-2: Der Warp-Antrieb für Windows-Entwickler:innen

The Windows update with the version: _KB5004296_ must be installed for this guide. (Minimum Requirement)

---

## Installing the WSL-2 under Windows 10/11

Open Windows Commandline with administrative privileges, and run the following:

```shell
wsl --install
```

Reboot your system

---

## Update your WSL-2

Open Windows Commandline with administrative privileges, and run the following:

```shell
wsl --update
```

---

## Installing and configure Ubuntu

Open Windows Commandline with administrative privileges again, and run the following:

```shell
wsl --install -d Ubuntu
```

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

### Install Java (SDKMAN with SapMachine17)

Download and install SDKMAN:

```shell
curl -s "https://get.sdkman.io" | bash
```

Next, open a new terminal or enter:
```shell
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

Install SapMachine17:

```shell
sdk install java 17.0.2-sapmchn
```

---

### Install Node.js (NVM with Latest LTS Version)

Download and install SDKMAN:

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

Copy files from Windows directly into the WSL:

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