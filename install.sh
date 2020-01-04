#!/bin/bash


WORKING_DIRECTORY="/tmp"
SYS_DEPENDENCIES=('git' 'ranger')

CONFIG_PATH="$HOME/.config/nvim"

is_config_installed() {
    if [[ -d $CONFIG_PATH ]]; then
        echo "A NeoVim configuration is already in place!"
        while true; do
            read -r -p "Would you like to back it up? [y/N]" yn
            case "$yn" in
                [Yy] ) backup_previous_config
                    break
                    ;;

                [Nn] ) break
                    ;;

                * ) echo "Please answer yes or no"
                    ;;
            esac
        done
    fi
}

check_dependencies() {
    echo "Checking dependencies..."

    for dep in "${SYS_DEPENDENCIES[@]}"; do
        which "$dep" > /dev/null 2>&1
        if [[ $? -eq 1 ]]; then
            echo "[Error] Broken dependency: $dep"
            exit 1
        fi
    done
}

backup_previous_config() {
    echo "Backing up previous config..."
    mv $CONFIG_PATH "$CONFIG_PATH.b-$(date +'%Y%d%m')"
}

install_config() {
    echo "Grabbing remote configuration..."

    # Remove conflicting setups if they exist
    if [[ -d $CONFIG_PATH ]]; then
        rm -rf $CONFIG_PATH
    fi

    git clone --recurse-submodules -j8 https://github.com/DrSpeedy/nvimrc.git $CONFIG_PATH
}

install_vundle_plugins() {
    echo "Installing plugins..."

    nvim -u $CONFIG_PATH/pre-init.vim +VundleInstall +qall
}

check_dependencies
is_config_installed
install_config
install_vundle_plugins

echo "Done."
