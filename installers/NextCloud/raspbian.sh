UPDATE_URL="https://raw.githubusercontent.com/dornathal/CloudBox/master/"
wget -q ${UPDATE_URL}/installers/NextCloud/common.sh -O /tmp/cloudboxcommon.sh
source /tmp/cloudboxcommon.sh && rm -f /tmp/cloudboxcommon.sh

function update_system_packages() {
    install_log "Updating sources"
    sudo apt-get update || install_error "Unable to update package list"
}

function install_dependencies() {
    install_log "Installing required packages"
    sudo apt-get install lighttpd php7.0 php7.0-gd php7.0-curl php7.0-common php7.0-intl php-pear php7.0-apcu php7.0-xml php7.0-mbstring php7.0-zip curl libcurl3 libcurl3-dev php7.0-mysql mariadb-server-10.1 smbclient || install_error "Unable to install dependencies"
}

nextcloud_install