#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
set -eEo pipefail
###############################################################################
# Description: script to show/enable/disable sybit proxy configuration of
#              different tools, when switching between moving between home and
#              flex office
# Args       : <none> | enable | disable
# Authors    : Andreas Becker, Joern Griepenburg
# Emails     : asb@sybit.de, jgg@sybit.de
# Version    : 28032023
###############################################################################

NO_COLOR="$(tput sgr0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"

PROXY_HOST="TBD"
PROXY_PORT="TBD"
PROXY_HTTP="http://${PROXY_HOST}:${PROXY_PORT}"

BASH_PROXY_CONFIG="/etc/profile.d/sybit-proxy.sh"
ZSH_PROXY_CONFIG="/etc/zsh/zprofile"
APT_PROXY_CONFIG="/etc/apt/apt.conf.d/98sybit-proxy"
CURL_PROXY_CONFIG="$HOME/.curlrc"
WGET_PROXY_CONFIG="$HOME/.wgetrc"
GRADLE_PROPERTIES="$HOME/.gradle/gradle.properties"
GRADLE_CONFIG_DIR="$(dirname "$GRADLE_PROPERTIES")"
MAVEN_CONFIG="$HOME/.m2/settings.xml"
MAVEN_CONFIG_DIR="$(dirname "$MAVEN_CONFIG")"

info_msg() {
  echo -e "${GREEN}$1${NO_COLOR}"
}

warning_msg() {
  echo -e "${YELLOW}$1${NO_COLOR}"
}

enabled_msg() {
  echo -e "${YELLOW}$1${NO_COLOR} proxy: \t${GREEN}enabled${NO_COLOR}"
}

disabled_msg() {
  echo -e "${YELLOW}$1${NO_COLOR} proxy: \t${RED}disabled${NO_COLOR}"
}

multiline_str() {
    printf '%s\n' "$@"
}

proxy_env_variables() {
    multiline_str "export http_proxy=$PROXY_HTTP" \
        "export HTTP_PROXY=$PROXY_HTTP" \
        "export https_proxy=$PROXY_HTTP" \
        "export HTTPS_proxy=$PROXY_HTTP"
}

view_current_proxy() {
    echo -e "\ncurrently used proxy: \t${GREEN}$HTTP_PROXY${NO_COLOR}"
    echo "You might need to restart your session, for the changes to take effect!"
}

unset_current_proxy() {
    unset http_proxy
    unset HTTP_PROXY
    unset https_proxy
    unset HTTPS_PROXY
}

# Bash ########################################
set_bash_proxy() {
    info_msg "Setting bash proxy in ${YELLOW}$BASH_PROXY_CONFIG${GREEN}..."

    proxy_env_variables | sudo tee "$BASH_PROXY_CONFIG" > /dev/null
    source "$BASH_PROXY_CONFIG"
}

unset_bash_proxy() {
    if [[ -f "$BASH_PROXY_CONFIG" ]]; then
        info_msg "Removing bash proxy config ${YELLOW}$GLOBAL_PROXY_CONFIG${GREEN}..."

        sudo rm -f "$BASH_PROXY_CONFIG"
        unset_current_proxy
    fi
}

view_bash_proxy() {
    if [[ -f "$BASH_PROXY_CONFIG" ]]; then
        enabled_msg "bash"
    else
        disabled_msg "bash"
    fi
}


# Zsh ########################################
is_zsh_available() {
    if ! type zsh &> /dev/null; then
        warning_msg "${RED}zsh${YELLOW} does not exist! Skipping..."
        return 1
    fi

    return 0
}

set_zsh_proxy() {
    info_msg "Setting zsh proxy in ${YELLOW}$ZSH_PROXY_CONFIG${GREEN}..."

    if is_zsh_available; then
        if grep -qE "(#)?export http_proxy" "$ZSH_PROXY_CONFIG" &> /dev/null; then
            sudo sed -i '/#export http/s/^#//g' "$ZSH_PROXY_CONFIG"
            sudo sed -i '/#export HTTP/s/^#//g' "$ZSH_PROXY_CONFIG"
        else
            proxy_env_variables | sudo tee -a "$ZSH_PROXY_CONFIG" > /dev/null
        fi
    fi
}

unset_zsh_proxy() {
    if is_zsh_available && grep -qE "^export http_proxy" "$ZSH_PROXY_CONFIG" &> /dev/null; then
        info_msg "Commenting out zsh proxy in ${YELLOW}$ZSH_PROXY_CONFIG${GREEN}..."

        sudo sed -i '/export http/s/^/#/g' "$ZSH_PROXY_CONFIG"
        sudo sed -i '/export HTTP/s/^/#/g' "$ZSH_PROXY_CONFIG"
    fi
}

view_zsh_proxy() {
    if grep -qE "^export http_proxy" "$ZSH_PROXY_CONFIG" &> /dev/null; then
        enabled_msg "zsh"
    else
        disabled_msg "zsh"
    fi
}


# APT ###########################################
set_apt_proxy() {
    info_msg "Setting apt proxy in ${YELLOW}$APT_PROXY_CONFIG${GREEN}..."

    apt_conf_proxy=$(multiline_str \
        "Acquire::http::Proxy \"$PROXY_HTTP\";" \
        "Acquire::https::Proxy \"$PROXY_HTTP\";" \
        "Acquire::ftp::Proxy \"$PROXY_HTTP\";" \
    )

    echo "$apt_conf_proxy" | sudo tee $APT_PROXY_CONFIG > /dev/null
}

unset_apt_proxy() {
    if [[ -f "$APT_PROXY_CONFIG" ]]; then
        info_msg "Removing apt proxy config ${YELLOW}$APT_PROXY_CONFIG${GREEN}..."

        sudo rm -f "$APT_PROXY_CONFIG"
    fi
}

view_apt_proxy() {
    if [[ -f "$APT_PROXY_CONFIG" ]]; then
        enabled_msg "apt"
    else
        disabled_msg "apt"
    fi
}


# CURL ##########################################
set_curl_proxy() {
    info_msg "Setting curl proxy in ${YELLOW}$CURL_PROXY_CONFIG${GREEN}..."

    curl_proxy="proxy=$PROXY_HTTP"

    if grep -qE "(#)?proxy" "$CURL_PROXY_CONFIG" &> /dev/null; then
        sed -i '/#proxy/s/^#//g' "$CURL_PROXY_CONFIG"
    else
        echo "$curl_proxy" >> "$CURL_PROXY_CONFIG"
    fi
}

unset_curl_proxy() {
    info_msg "Commenting out curl proxy in ${YELLOW}$CURL_PROXY_CONFIG${GREEN}..."

    if grep -qE "^proxy" "$CURL_PROXY_CONFIG" &> /dev/null; then
        sed -i '/proxy/s/^/#/g' "$CURL_PROXY_CONFIG"
    fi
}

view_curl_proxy() {
    if grep -qE "^proxy" "$CURL_PROXY_CONFIG" &> /dev/null; then
        enabled_msg "curl"
    else
        disabled_msg "curl"
    fi
}


# WGET ##########################################
set_wget_proxy() {
    info_msg "Setting wget proxy in ${YELLOW}$WGET_PROXY_CONFIG${GREEN}..."

    wget_proxy=$(multiline_str \
        "http_proxy = $PROXY_HTTP" \
        "https_proxy = $PROXY_HTTP" \
        "use_proxy = on" \
    )

    if grep -qE "(#)?use_proxy" "$WGET_PROXY_CONFIG" &> /dev/null; then
        # if proxy config exsist, but is commented out comment it back in
        sed -i '/#use_proxy/s/^#//g' "$WGET_PROXY_CONFIG"
    else
        echo "$wget_proxy" >> "$WGET_PROXY_CONFIG"
    fi
}

unset_wget_proxy() {
    info_msg "Commenting out wget proxy in ${YELLOW}$WGET_PROXY_CONFIG${GREEN}..."

    if grep -qE "^use_proxy" "$WGET_PROXY_CONFIG" &> /dev/null; then
        sed -i '/use_proxy/s/^/#/g' "$WGET_PROXY_CONFIG"
    fi
}

view_wget_proxy() {
    if grep -qE "^use_proxy" "$WGET_PROXY_CONFIG" &> /dev/null; then
        enabled_msg "wget"
    else
        disabled_msg "wget"
    fi
}


# GIT ###########################################
is_git_available() {
    if ! type git &> /dev/null; then
        warning_msg "${RED}git${YELLOW} cli does not exist! Skipping..."
        return 1
    fi

    return 0
}

set_git_proxy() {
    info_msg "Setting up git proxy..."

    if is_git_available; then
        git config --global http.proxy "$PROXY_HTTP"
        git config --global https.proxy "$PROXY_HTTP"
    fi
}

unset_git_proxy() {
    info_msg "Unsetting git proxy..."

    if is_git_available && git config --global --get https.proxy > /dev/null; then
        git config --global --unset http.proxy
        git config --global --unset https.proxy
    fi
}

view_git_proxy() {
    if git config --global --get https.proxy &> /dev/null; then
        enabled_msg "git"
    else
        disabled_msg "git"
    fi
}


# GRADLE ########################################
is_gradle_dir_available() {
    if [[ ! -d "$GRADLE_CONFIG_DIR" ]]; then
        warning_msg "Gradle config dir ${RED}$GRADLE_CONFIG_DIR${YELLOW} does not exist! Skipping..."
        return 1
    fi

    return 0
}

gradle_properties_without_proxy() {
    temp_gradle_properties=$(mktemp)

    grep -vE '^systemProp.https?.proxy(Host|Port)' "$GRADLE_PROPERTIES" \
        > "$temp_gradle_properties"

    cat "$temp_gradle_properties"
}

set_gradle_proxy() {
    info_msg "Setting gradle proxy in ${YELLOW}$GRADLE_PROPERTIES${GREEN}..."

    gradle_proxy=$(multiline_str \
        "systemProp.http.proxyHost=$PROXY_HOST" \
        "systemProp.http.proxyPort=$PROXY_PORT" \
        "systemProp.https.proxyHost=$PROXY_HOST" \
        "systemProp.https.proxyPort=$PROXY_PORT" \
    )

    if is_gradle_dir_available; then
        gradle_config="$(gradle_properties_without_proxy)\n$gradle_proxy"
        echo "$gradle_config" > "$GRADLE_PROPERTIES"
    fi
}

unset_gradle_proxy() {
    info_msg "Removing gradle proxy from ${YELLOW}$GRADLE_PROPERTIES${GREEN}..."

    if is_gradle_dir_available; then
        gradle_config="$(gradle_properties_without_proxy)"
        echo "$gradle_config" > "$GRADLE_PROPERTIES"
    fi
}

view_gradle_proxy() {
    if grep -qE "^systemProp.https?.proxy(Host|Port)" "$GRADLE_PROPERTIES" &> /dev/null; then
        enabled_msg "gradle"
    else
        disabled_msg "gradle"
    fi
}


# MAVEN #########################################
is_maven_dir_available() {
    if [[ ! -d "$MAVEN_CONFIG_DIR" ]]; then
        warning_msg "Maven config dir ${RED}$MAVEN_CONFIG_DIR${YELLOW} does not exist! Skipping..."
        return 1
    fi

    return 0
}

set_maven_proxy() {
    info_msg "Setting maven proxy in ${YELLOW}$MAVEN_CONFIG${GREEN}..."

    maven_proxy=$(multiline_str \
        "<settings>" \
        "  <proxies>" \
        "    <proxy>" \
        "      <active>true</active>" \
        "      <protocol>http</protocol>" \
        "      <host>$PROXY_HOST</host>" \
        "      <port>$PROXY_PORT</port>" \
        "    </proxy>" \
        "  </proxies>" \
        "</settings>" \
    )

    if is_maven_dir_available; then
        if grep -qE "<active>(true|false)</active>" "$MAVEN_CONFIG" &> /dev/null; then
            sed -i 's/<active>false/<active>true/g' "$MAVEN_CONFIG"
        else
            echo "$maven_proxy" >> "$MAVEN_CONFIG"
        fi
    fi
}

unset_maven_proxy() {
    info_msg "Disabling maven proxy in ${YELLOW}$MAVEN_CONFIG${GREEN}..."

    if is_maven_dir_available; then
        if grep -qE "<active>true</active>" "$MAVEN_CONFIG" &> /dev/null; then
            sed -i 's/<active>true/<active>false/g' "$MAVEN_CONFIG"
        fi
    fi
}

view_maven_proxy() {
    if grep -qE "<active>true</active>" "$MAVEN_CONFIG" &> /dev/null; then
        enabled_msg "maven"
    else
        disabled_msg "maven"
    fi
}


# NPM ###########################################
is_npm_available() {
    if ! type npm &> /dev/null; then
        warning_msg "${RED}npm${YELLOW} cli does not exist! Skipping..."
        return 1
    fi

    if [[ "$(which npm)" =~ "/mnt/c/Users" ]]; then
        warning_msg "${RED}npm${YELLOW} cli only exists in windows! Skipping..."
        return 1
    fi

    return 0
}

set_npm_proxy() {
    info_msg "Setting npm proxy..."

    if is_npm_available; then
        npm config set proxy "$PROXY_HTTP"
    fi
}

unset_npm_proxy() {
    info_msg "Removing npm proxy..."

    if is_npm_available; then
        npm config delete proxy
    fi
}

view_npm_proxy() {
    if is_npm_available && ! npm config get proxy | grep -q "null"; then
        enabled_msg "npm"
    else
        disabled_msg "npm"
    fi
}

enable_proxy() {
    set_bash_proxy
    set_zsh_proxy
    set_apt_proxy
    set_curl_proxy
    set_wget_proxy
    set_git_proxy
    set_gradle_proxy
    set_maven_proxy
    set_npm_proxy
}

disable_proxy() {
    unset_bash_proxy
    unset_zsh_proxy
    unset_apt_proxy
    unset_curl_proxy
    unset_wget_proxy
    unset_git_proxy
    unset_gradle_proxy
    unset_maven_proxy
    unset_npm_proxy
}

show_settings() {
    view_bash_proxy
    view_zsh_proxy
    view_apt_proxy
    view_curl_proxy
    view_wget_proxy
    view_git_proxy
    view_gradle_proxy
    view_maven_proxy
    view_npm_proxy
    view_current_proxy
}

if [[ "$1" = "enable" ]]; then
    enable_proxy

    echo && show_settings
elif [[ "$1" = "disable" ]]; then
    disable_proxy

    echo && show_settings
else
    show_settings
fi