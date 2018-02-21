
lighttpd_user="www-data"
version=`sed 's/\..*//' /etc/debian_version`

# Determine version, set default home location for lighttpd and 
# php package to install 
webroot_dir="/var/www/html" 
install_dir="$webroot_dir/nextcloud"
data_dir="/data/nextcloud"

# Outputs a NextCloud Install log line
function install_log() {
    echo -e "\033[1;32mNextCloud Install: $*\033[m"
}

# Outputs a NextCloud Install Error log line and exits with status code 1
function install_error() {
    echo -e "\033[1;37;41mNextCloud Install Error: $*\033[m"
    exit 1
}

# Outputs a welcome message
function display_welcome() {
    raspberry='\033[0;35m'
    green='\033[1;32m'

    echo -e "${raspberry}\n"
    echo -e "  _   _           _    ____ _                 _ "
    echo -e " | \ | | _____  _| |_ / ___| | ___  _   _  __| |"
    echo -e " |  \| |/ _ \ \/ / __| |   | |/ _ \| | | |/  \` |"
    echo -e " | |\  |  __/>  <| |_| |___| | (_) | |_| | (_| |"
    echo -e " |_| \_|\___/_/\_\___|\____|_|\___/ \__,_|\__,_|"
    echo -e "${green}"
    echo -e "The Quick Installer will guide you through a few easy steps\n\n"
}

### NOTE: all the below functions are overloadable for system-specific installs
### NOTE: some of the below functions MUST be overloaded due to system-specific installs

function config_installation() {
    install_log "Configure installation"
    echo "Detected ${version_msg}" 
    echo "Install directory: ${install_dir}"
    echo "Data directory: ${data_dir}"
    echo -n "Complete installation with these values? [y/N]: "
    read answer
    if [[ $answer != "y" ]]; then
        echo "Installation aborted."
        exit 0
    fi
}

# Runs a system software update to make sure we're using all fresh packages
function update_system_packages() {
    # OVERLOAD THIS
    install_error "No function definition for update_system_packages"
}

# Installs additional dependencies using system package manager
function install_dependencies() {
    # OVERLOAD THIS
    install_error "No function definition for install_dependencies"
}

# Enables PHP for lighttpd and restarts service for settings to take effect
function enable_php_lighttpd() {
    install_log "Enabling PHP for lighttpd"

    sudo lighttpd-enable-mod fastcgi-php    
    sudo service lighttpd force-reload
    sudo /etc/init.d/lighttpd restart || install_error "Unable to restart lighttpd"
}

# Verifies existence and permissions of NextCloud directory
function create_directories() {
    install_log "Creating NextCloud directories"
    if [ -d "$data_dir" ]; then
        sudo mv $data_dir "$data_dir.`date +%F-%R`" || install_error "Unable to move old '$data_dir' out of the way"
    fi
    sudo mkdir -p "$data_dir" || install_error "Unable to create directory '$data_dir'"
    sudo chown -R $lighttpd_user:$lighttpd_user "$data_dir" || install_error "Unable to change file ownership for '$data_dir'"
}

# Fetches latest files from github to webroot
function download_latest_files() {
    if [ -d "$install_dir" ]; then
        sudo mv $install_dir "$install_dir.`date +%F-%R`" || install_error "Unable to remove old '$install_dir' out of the way"
    fi

    install_log "Downloading Nextcloud"
    cd $webroot_dir
    sudo wget https://download.nextcloud.com/server/releases/latest.zip
    sudo unzip latest.zip
    sudo rm latest.zip
}

# Sets files ownership in web root directory
function change_file_ownership() {
    if [ ! -d "$webroot_dir" ]; then
        install_error "Web root directory doesn't exist"
    fi

    install_log "Changing file ownership in web root directory"
    sudo chown -R $lighttpd_user:$lighttpd_user "$webroot_dir" || install_error "Unable to change file ownership for '$webroot_dir'"
}

# Create database for nextcloud
function create_database() {
    install_log "Creating database for nextcloud"
    read -p "Choose password for NextCloud:" nextcloud_password
    sudo mariadb -e "
    CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
    CREATE USER nextcloud@localhost identified by '$nextcloud_password';
    GRANT ALL PRIVILEGES on nextcloud.* to nextcloud@localhost;
    FLUSH privileges; "
}

function install_complete() {
    install_log "Installation completed!"

    echo -n "The system needs to be rebooted as a final step. Reboot now? [y/N]: "
    read answer
    if [[ $answer != "y" ]]; then
        echo "Installation aborted."
        exit 0
    fi
    sudo shutdown -r now || install_error "Unable to execute shutdown"
}

function nextcloud_install() {
    display_welcome
    config_installation
    update_system_packages
    install_dependencies
    enable_php_lighttpd
    create_directories
    create_database
    download_latest_files
    change_file_ownership
    install_complete
}