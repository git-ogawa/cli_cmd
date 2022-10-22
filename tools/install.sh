#!/bin/bash
# Install packages on the executed node.
# Set PACKAGE_MANAGER according to package manager in the script, then run ./install.sh

set -eu

function package_prefix () {
    case $1 in
        apt)
            echo "deb"
            ;;
        dnf)
            echo "rpm"
            ;;
        *)
            ;;
    esac
}

# Package manager. Set dnf or apt.
PACKAGE_MANAGER="dnf"
PACKAGE_EXT=$(package_prefix ${PACKAGE_MANAGER})

if [[ ${PACKAGE_MANAGER} != "apt" && ${PACKAGE_MANAGER} != "dnf" ]]; then
    echo "${PACKAGE_MANAGER} is unknown package manager. Set apt or dnf."
    exit 1
fi

# Path where binary commands will be put.
BIN_PATH="/usr/local/bin"
# Commands required to install the packages.
DEPS=(
    curl
    git
)
# Packages to be installed with package manager.
PACKAGES=(
    htop
    ranger
)
# Packages to be installed by downloading binaries from github.
PACKAGES_BIN=(
    fd
    gdu
    bat
)
# Packages to be installed by downloading packages from github.
PACKAGES_BIN_MANAGER=(
    duf
)

declare -A PACKAGES_VERSION=(
    ["fd"]="8.4.0"
    ["bat"]="0.22.1"
    ["gdu"]="latest"
    ["duf"]="0.8.1"
)

declare -A PACKAGES_URL=(
    ["fd"]="https://github.com/sharkdp/fd/releases/download/v${PACKAGES_VERSION[fd]}/fd-v${PACKAGES_VERSION[fd]}-x86_64-unknown-linux-gnu.tar.gz"
    ["gdu"]="https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz"
    ["bat"]="https://github.com/sharkdp/bat/releases/download/v${PACKAGES_VERSION[bat]}/bat-v${PACKAGES_VERSION[bat]}-x86_64-unknown-linux-gnu.tar.gz"
    ["duf"]="https://github.com/muesli/duf/releases/download/v${PACKAGES_VERSION[duf]}/duf_${PACKAGES_VERSION[duf]}_linux_amd64.${PACKAGE_EXT}"
)

# Binary filename in tar.gz
declare -A BIN_NAME=(
    ["fd"]="fd"
    ["gdu"]="gdu_linux_amd64"
    ["bat"]="bat"
    ["duf"]="duf"
)

declare -A STRIP_NUM=(
    ["fd"]="1"
    ["gdu"]="0"
    ["bat"]="1"
    ["duf"]="0"
)

# Check binary command exists in ${BIN_PATH}
function is_installed () {
    res=$(which ${BIN_PATH}/${1} >/dev/null 2>&1; echo $?)
    echo ${res}
}

# Download the package binary from github release and put it in the ${BIN_PATH}.
# The required arguments are the followings.
# $1 : The command name
# $2 : The package url. This is usaully the package in github release page.
# $3 : The binary name of the package in tar gz
# $4 : How many levels of binaries exist in the tar.gz.
function install_from_git () {
    local name=$1
    local url=$2
    local _tar=${name}.tar.gz
    local notar="${name}_bin"
    local bin_name=${3}
    local strip_num=${4:-0}

    ret=$(is_installed ${name})
    if [[ ${ret} == 0 ]]; then
        echo "${name} already installed in ${BIN_PATH}. so skip the installation."
        return 0
    fi

    curl -LSs ${url} -o /tmp/${_tar}
    mkdir -p /tmp/${notar}
    tar zxf /tmp/${_tar} -C /tmp/${notar} --strip-components ${strip_num}
    sudo cp /tmp/${notar}/${bin_name} ${BIN_PATH}/${name}
    sudo chmod +x ${BIN_PATH}/${name}
    echo "Install ${name} in ${BIN_PATH}."
}

# Download the package from github release and install it with package manager.
# The required arguments are the followings.
# $1 : The package url. This is usaully the package name in github release page.
function packge_manager_from_git () {
    local url=$1
    local basename=$(basename ${url})

    curl -LSs ${url} -o /tmp/${basename}
    sudo ${PACKAGE_MANAGER} install -y /tmp/${basename}
}

# Install packages that can be installed with package manager.
function install_package () {
    if [[ ${PACKAGE_MANAGER} == "apt" ]]; then
        sudo ${PACKAGE_MANAGER} update
    fi
    sudo ${PACKAGE_MANAGER} install -y ${DEPS[@]}
    sudo ${PACKAGE_MANAGER} install -y $@
}

echo "Start install procedure."
echo $(printf "%060d\n" 0 | sed "s/0/-/g")

install_package ${PACKAGES[@]}

for package in ${PACKAGES_BIN[@]}
do
    install_from_git \
        ${package} \
        ${PACKAGES_URL["${package}"]} \
        ${BIN_NAME["${package}"]} \
        ${STRIP_NUM["${package}"]}
done

for package in ${PACKAGES_BIN_MANAGER[@]}
do
    packge_manager_from_git \
        ${PACKAGES_URL["${package}"]}
done

echo $(printf "%060d\n" 0 | sed "s/0/-/g")
echo "Install procedure succesufully finished."
