#!/bin/bash

clear
# Clear screen before running any commands

REQUIREMENTS_INSTALLED=0

install_fail () {
    echo "Install Failed."
    exit 1
}

install_debian () {
    sudo apt install python3 python3-tk python3-pip git || install_fail
}

install_fedora () {
    sudo dnf install python3 python3-tkinter python3-pip git || install_fail
}

install_centos () {
    sudo yum install -y python3 || install_fail
    rpm -q epel-release &> /dev/null || EPEL=0
    sudo yum install -y python3-tkinter epel-release python3-pip git || install_fail
    # Honestly not sure why it's installing epel and then uninstalling
    [[ $EPEL -eq 0 ]] && sudo yum remove -y epel-release
}

install_arch () {
    sudo pacman -S --needed python3 tk git && python3 -m ensurepip || install_fail
}

install_macos() {
    echo "This script will install homebrew, if you do not wish to install homebrew, exit within 5 seconds..."
    sleep 5
    if test ! $(which brew); then
        #Install homebrew
        echo "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Install python3.10 & git or fail out
    brew install python@3.10 && \
    brew install git || \
        install_fail
}

install_python_requirements () {
    python3 -m pip install -q -r requirements.txt --user && \
        echo "Python requirements installed." || exit 1
    # Pip should give an error if it fails.
}

install_os_requirements () {
    echo "YT-Spammer-Purge has a few requirements that you will need to install."
    sleep 1


    # Check for known OS's
    INSTALLED=0

    case "$(uname -s)" in
        Darwin*) install_macos && INSTALLED=1 || install_fail;;
        # Mac
        #CYGWIN*) do_something;;
        # Cygwin Emulator -- Unimplemented
        #MINGW*) do_something;;
        # MINGW Emulator -- Unimplemented
    esac

    [[ -e /etc/debian_version ]] && install_debian && INSTALLED=1

    [[ -e /etc/fedora-release ]] && install_fedora && INSTALLED=1

    [[ -e  /etc/centos-release ]] && install_centos && INSTALLED=1

    [[ -e /etc/arch-release ]] && install_arch && INSTALLED=1

    [[ $INSTALLED -eq 0 ]] && printf "You are on an unknown system. You will have to install the required packages manually.\nContributions are welcome to add support for your system:\nhttps://github.com/ThioJoe/YT-Spammer-Purge" && exit 1

}

install_latest_release () {
    echo "We are now going to download the code for YT-Spammer-Purge."
    sleep 1
    git clone https://github.com/ThioJoe/YT-Spammer-Purge
    cd YT-Spammer-Purge
    git checkout -q -m $(git describe --abbrev=0 --tags)
    # Go to latest release
}

install_MAIN () {
    clear
    echo "We will now install YT-Spammer-Purge. If this is not what you intend to do, exit within 5 seconds..."
    sleep 5
    echo "Installing."
    # Check what OS we're running on

    # Check if we already installed the requirements -- git is needed to check for which mode to run.
    [[ $REQUIREMENTS_INSTALLED -eq 0 ]] && install_os_requirements

    echo "--------------------------"

    install_latest_release

    # Since we've gotten python3 installed:

    echo "--------------------------"
    install_python_requirements

    # Done!

    printf "Dependencies and Program installed into .\YT-Spammer-Purge!\nNow follow these instructions to get a client_secrets.json file!\nhttps://github.com/ThioJoe/YT-Spammer-Purge/wiki/Instructions:-Obtaining-an-API-Key\n\nYou may run this script again inside your installation to update.\n"
    exit 1
}

update () {
    clear
    echo "We will now update YT-Spammer-Purge. If this is not what you intend to do, exit within 5 seconds..."
    sleep 5
    echo "Continuing."
    echo "Current version is $(git describe --abbrev=0 --tags)"
    echo "Updating..."


    git fetch origin
    echo "Latest version is $(git describe origin --abbrev=0 --tags)"
    echo "Updating to this version."
    git checkout -q -m $(git describe origin --abbrev=0 --tags)


    echo "--------------------------"
    echo "Updated!"
    echo "Report any bugs to TJoe.io/bug-report"
    exit 1
}

git_missing () {
    clear
    echo "It looks like you downloaded a .zip of YT-Spammer-Purge"
    echo "Automated updates do not work on these versions, but you may download the latest version of YT-Spammer-Purge using this script."
    echo "If you choose to re-download the latest verion of YT-Spammer-Purge using this script, automated updates will be re-enabled."
    echo "The latest YT-Spammer-Purge with automated updates will be downloaded to a sub-directory of the same name."
    echo "If you would not like to install YT-Spammer-Purge using this script, close this script within the next 15 seconds..."
    sleep 15
    install_MAIN
    exit 1
}

if ! command -v git &> /dev/null
then
    echo "You are missing some required packages to run this script."
    install_os_requirements
    REQUIREMENTS_INSTALLED=1
fi

[[ -e YTSpammerPurge.py ]] && ( [[ $(git remote get-url origin) == *"YT-Spammer-Purge"* ]] || git_missing )

[[ $(git remote get-url origin) == *"YT-Spammer-Purge"* ]] && update || install_MAIN
# If get-url succeeds, update, else install
