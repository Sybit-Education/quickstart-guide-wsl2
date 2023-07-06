# Intellij IDEA Ultimate

[Install the JetBrains Toolbox for the latest version](https://www.jetbrains.com/de-de/toolbox-app/) and easy updating in the future. 

Update your IDEA regularly because improvements and bugs for the WSL-2 are released all the time.

## Import the Project

The project can be imported via the network access

```shell
\\wsl$\Ubuntu
```

---

## Necessary adjustments

In `idea.properties` _Help | Edit Custom Properties_ and add the following:

`idea.case.sensitive.fs=true`

---

## Make sure

### Correct JDK

In _File_ | `Project Structure` | _Project_

It must be the installed JDK on your distribution (Not the Windows installation)

---

### Correct Node.js interpreter

In _File_ | `Settings` | search for _Node_

Select the Node interpreter based on your current installation (Not the Windows installation)