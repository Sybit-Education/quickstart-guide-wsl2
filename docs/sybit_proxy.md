# Adding the sy_proxy tool

Some people responded, that the file had wrong line endings. 
If you also get the error, you can fix that issue by the following command inside your WSL

```shell
dos2unix.exe ~/sybit-proxy.sh
```

Open the `.bashrc` (or `.zshrc` depending on your shell) file with your terminal editor (e.g. `nano`)
 
```shell
nano ~/.bashrc
```

and add the following entries into the alias section or at the end of the file

```shell
alias sy_proxy_enable="~/sybit-proxy.sh enable"
alias sy_proxy_disable="~/sybit-proxy.sh disable"
alias sy_proxy_status="~/sybit-proxy.sh"
```

save your changes and reload the configuration with the following commands to finish the installation.

```shell
source ~/.bashrc
```

You are now able to enable the proxy settings by using the following command

```shell
sy_proxy_enable
```

To disable the proxy settings you can use the `sy_proxy_disable` command and if you're unsure which configuration
is currently set, check the proxy configuration with `sy_proxy_status`.

## Supported tools

| Tool   | version    |
| ------ | ---------- |
| apt    | 20210719.1 |
| curl   | 20210719.1 |
| git    | 20210716   |
| global | 20210716   |
| gradle | 20210719.1 |
| maven  | 20210719.1 |
| npm    | 20210719.1 |
| wget   | 20210719.1 |