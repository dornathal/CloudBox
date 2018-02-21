
UPDATE_URL="https://raw.githubusercontent.com/dornathal/CloudBox/master/"

# Outputs a welcome message
function display_welcome() {
    raspberry='\033[0;35m'
    green='\033[1;32m'

    echo -e "${raspberry}\n"
    echo -e "   ____ _                 _ ____            "
    echo -e "  / ___| | ___  _   _  __| | __ )  _____  __"
    echo -e " | |   | |/ _ \| | | |/ _\` |  _ \ / _ \ \/ /"
    echo -e " | |___| | (_) | |_| | (_| | |_) | (_) >  < "
    echo -e "  \____|_|\___/ \__,_|\__,_|____/ \___/_/\_\ "

    echo -e "${green}"
    echo -e "The Quick Installer will guide you through installing the CloudBox\n\n"
    echo -e "${raspberry}\n"
    echo -e "CloudBox installs various applications. At the end of each installation you will be prompted to reboot the system. SKIP until asked in this color.$*\033[m\n\n"
}

# Outputs a Install log line
function install_log() {
    echo -e "\033[1;32mInstall: $*\033[m"
}

# Outputs a Install Error log line and exits with status code 1
function install_error() {
    echo -e "\033[1;37;41mInstall Error: $*\033[m"
    exit 1
}

function install_rasp_ap() {
    echo -n "Install RaspAP? [y/N]: "
    read answer
    if [[ $answer == "y" ]]; then
	wget -q https://git.io/voEUQ -O /tmp/raspap && bash /tmp/raspap
        sudo mv /var/www/html /var/www/wifi
        sudo mkdir -p /var/www/html/config/wifi
        sudo mv /var/www/wifi /var/www/html/config
    fi
}

function install_nextcloud() {
    echo -n "Install NextCloud? [y/N]: "
    read answer
    if [[ $answer == "y" ]]; then
	wget -q ${UPDATE_URL}/installers/NextCloud/raspbian.sh -O /tmp/nextcloud && bash /tmp/nextcloud
    fi
}

function install_complete() {
    install_log "CloudBox installation completed!"

    echo -e "\033[0;35m The system needs to be rebooted as a final step. Reboot now? [Y/n]: $*\033[m"
    read answer
    if [[ $answer != "n" ]]; then
        sudo shutdown -r now || install_error "Unable to execute shutdown"
    fi
}

function install() {
    display_welcome
    install_rasp_ap
    install_nextcloud
    install_complete
}

install