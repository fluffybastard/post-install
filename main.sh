#!/bin/bash
#
# USAGE : Install and configure the following components :
#				- epel repository
#				- transmisison server
#				- nginx webserver
#				- samba
# 				- ftp server
#				- sshd config
#				- wget
#				- iptables rules
#				- grab plexmediaserver.rpm
#				- custom .vimrc file
#				- custom cronjobs

# -- Clear the screen before executing the script
/usr/bin/clear

# -- Import colors and default file paths
source ./configs/colors.ini
source ./configs/file_paths.ini

# -- Check for missing packages and install them
function check_epel {
	
	local EPEL_CHECK

	EPEL_CHECK=$(rpm -qa | grep epel-release)

	if [ $? != 0 ]; then
		printf "${RED}%-67s${END_COLOR} ${GREEN}%-5s${END_COLOR}\n" "* epel-release" [INSTALLING]
		yum install epel-release -y 1> /dev/null
	else
		printf "${BLUE}%-72s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* epel-release" [FOUND]
	fi

}

function check_transmission_daemon {

	local TRANSMISSION_CHECK

	TRANSMISSION_CHECK=$(rpm -qa | grep transmission)

	if [ $? != 0 ]; then
		printf "${RED}%-67s${END_COLOR} ${GREEN}%-5s${END_COLOR}\n" "* transmission" [INSTALLING]
		yum install transmission-daemon transmission-common transmission-cli -y 1> /dev/null
		
		# -- Start and stop the service to generate default settings.json
		systemctl start transmission-daemon 1> /dev/null
		systemctl stop transmission-daemon 1> /dev/null
	else
		printf "${BLUE}%-72s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* transmission" [FOUND]
	fi

}

function check_nginx {

	local NGINX_CHECK

	NGINX_CHECK=$(rpm -qa | grep nginx)

	if [ $? != 0 ]; then
		printf "${RED}%-67s${END_COLOR} ${GREEN}%-5s${END_COLOR}\n" "* nginx" [INSTALLING]
		yum install nginx -y 1> /dev/null
	else
		printf "${BLUE}%-72s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* nginx" [FOUND]
	fi

}

function check_samba {

	local SAMBA_CHECK

	SAMBA_CHECK=$(rpm -qa | grep samba)

	if [ $? != 0 ]; then
		printf "${RED}%-67s${END_COLOR} ${GREEN}%-5s${END_COLOR}\n" "* samba" [INSTALLING]
		yum install samba -y 1> /dev/null
	else
		printf "${BLUE}%-72s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* samba" [FOUND]
	fi

}

function check_vsftpd {

	local VSFTP_CHECK

	VSFTP_CHECK=$(rpm -qa | grep vsftpd)

	if [ $? != 0 ]; then
		printf "${RED}%-67s${END_COLOR} ${GREEN}%-5s${END_COLOR}\n" "* vsftpd" [INSTALLING]
		yum install vsftpd -y 1> /dev/null
	else
		printf "${BLUE}%-72s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* vsftpd" [FOUND]
	fi

}

function check_wget {

	local WGET_CHECK

	WGET_CHECK=$(rpm -qa | grep wget)

	if [ $? != 0 ]; then
		printf "${RED}%-67s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* wget" [INSTALLING]
		yum install wget -y 1> /dev/null
	else
		printf "${BLUE}%-72s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* wget" [FOUND]
	fi

}

function check_iptables {

	local IPTABLES_CHECK

	IPTABLES_CHECK=$(rpm -qa | grep iptables)

	if [ $? != 0 ]; then
		printf "${RED}%-67s${END_COLOR} ${GREEN}%-5s${END_COLOR}\n" "* iptables" [INSTALLING]
		yum install iptables -y 1> /dev/null
	else
		printf "${BLUE}%-72s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* iptables" [FOUND]
	fi

}

function check_vim {

	local VIM_CHECK

	VIM_CHECK=$(rpm -qa | grep vim)

	if [ $? != 0 ]; then
		printf "${RED}%-67s${END_COLOR} ${GREEN}%-5s${END_COLOR}\n" "* vim" [INSTALLING]
		yum install vim -y 1> /dev/null
	else
		printf "${BLUE}%-72s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* vim" [FOUND]
	fi

}

function grab_plex {

	# -- Will have to manually adjust the download link for future versions
	# -- It is a work in progress

	local PLEX_CHECK

	PLEX_CHECK=$(rpm -qa | grep plexmediaserver)

	if [ $? != 0 ]; then
		check_wget
		printf "${RED}%-67s${END_COLOR} ${GREEN}%-5s${END_COLOR}\n" "* plexmediaserver" [INSTALLING]
		wget -q  https://downloads.plex.tv/plex-media-server/1.4.4.3495-edef59192/plexmediaserver-1.4.4.3495-edef59192.x86_64.rpm -O /tmp/plexmediaserver.rpm
		yum install /tmp/plexmediaserver.rpm -y 1> /dev/null
		systemctl stop plexmediaserver 1> /dev/null
	else
		printf "${BLUE}%-72s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* plexmediaserver" [FOUND]
	fi

}

# -- Back up configs
function backup_initial_configs {

	local DATE
	DATE=$(date +"%d-%m-%Y")

	printf "\n${YELLOW}\t- Back up original configuration files to FILE.${DATE} -${END_COLOR}\n\n"

	# -- Backup transmission-daemon settings.json
	if [ -e ${DEFAULT_TRANSMISSION_CONF} ]; then
		printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${DEFAULT_TRANSMISSION_CONF}.${DATE} [OK]
		cp ${DEFAULT_TRANSMISSION_CONF} ${DEFAULT_TRANSMISSION_CONF}.${DATE}
	else 
		printf "${RED}%-70s${END_COLOR} ${RED}%s${END_COLOR}\n" ${DEFAULT_TRANSMISSION_CONF} [MISSING]
	fi

	# -- Backup nginx.conf
	if [ -e ${DEFAULT_NGINX_CONF} ];then
		printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${DEFAULT_NGINX_CONF}.${DATE} [OK]
		cp ${DEFAULT_NGINX_CONF} ${DEFAULT_NGINX_CONF}.${DATE}
	else
		printf "${RED}%-70s${END_COLOR} ${RED}%s${END_COLOR}\n" ${DEFAULT_NGINX_CONF} [MISSING]
	fi

	# -- Backup nginx backends.conf
	if [ -e ${DEFAULT_NGINX_BACKENDS} ];then
		printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${DEFAULT_NGINX_BACKENDS}.${DATE} [OK]
		cp ${DEFAULT_NGINX_BACKENDS} ${DEFAULT_NGINX_BACKENDS}.${DATE}
	else
		printf "${RED}%-70s${END_COLOR} ${RED}%s${END_COLOR}\n" ${DEFAULT_NGINX_BACKENDS} [MISSING]
	fi

	# -- Backup nginx proxy.conf
	if [ -e ${DEFAULT_NGINX_PROXY} ];then
		printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${DEFAULT_NGINX_PROXY}.${DATE} [OK]
		cp ${DEFAULT_NGINX_PROXY} ${DEFAULT_NGINX_PROXY}.${DATE}
	else
		printf "${RED}%-70s${END_COLOR} ${RED}%s${END_COLOR}\n" ${DEFAULT_NGINX_PROXY} [MISSING]	
	fi

	# -- Backup smb.conf
	if [ -e ${DEFAULT_SAMBA_CONF} ];then
		printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${DEFAULT_SAMBA_CONF}.${DATE} [OK]
		cp ${DEFAULT_SAMBA_CONF} ${DEFAULT_SAMBA_CONF}.${DATE}
	else
		printf "${RED}%-70s${END_COLOR} ${RED}%s${END_COLOR}\n" ${DEFAULT_SAMBA_CONF} [MISSING]
	fi

	# -- Backup vsftpd.conf
	if [ -e ${DEFAULT_VSFTPD_CONF} ];then
		printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${DEFAULT_VSFTPD_CONF}.${DATE} [OK]
		cp ${DEFAULT_VSFTPD_CONF} ${DEFAULT_VSFTPD_CONF}.${DATE}
	else
		printf "${RED}%-70s${END_COLOR} ${RED}%s${END_COLOR}\n" ${DEFAULT_VSFTPD_CONF} [MISSING]
	fi

	# -- Backup sshd_config
	if [ -e ${DEFAULT_SSHD_CONF} ];then
		printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${DEFAULT_SSHD_CONF}.${DATE} [OK]
		cp ${DEFAULT_SSHD_CONF} ${DEFAULT_SSHD_CONF}.${DATE}
	else
		printf "${RED}%-70s${END_COLOR} ${RED}%s${END_COLOR}\n" ${DEFAULT_SSHD_CONF} [MISSING]
	fi

	# -- Backup .vimrc
	if [ -e ${DEFAULT_VIM_CONF} ];then
		printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${DEFAULT_VIM_CONF}.${DATE} [OK]
		cp ${DEFAULT_VIM_CONF} ${DEFAULT_VIM_CONF}.${DATE}
	else
		printf "${RED}%-70s${END_COLOR} ${RED}%s${END_COLOR}\n" ${DEFAULT_VIM_CONF} [MISSING]
	fi

	# -- Backup root cronjobs
	if [ -e ${DEFAULT_ROOT_CRONJOBS} ];then
		printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${DEFAULT_ROOT_CRONJOBS}.${DATE} [OK]
		cp ${DEFAULT_ROOT_CRONJOBS} ${DEFAULT_ROOT_CRONJOBS}.${DATE}
	else
		printf "${RED}%-70s${END_COLOR} ${RED}%s${END_COLOR}\n" ${DEFAULT_ROOT_CRONJOBS} [MISSING]
	fi

}

# -- Custom configs
function copy_custom_config {

	printf "\n${YELLOW}\t- Copying new configuration files from 'app_files' directory -${END_COLOR}\n\n"

	# -- Restore transmission settings.conf
	printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_TRANSMISSION_CONF} [OK]
	cp ${CUSTOM_TRANSMISSION_CONF} ${DEFAULT_TRANSMISSION_CONF}

	# -- Restore torrent cache into default transmission directory
	printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_TRANSMISSION_TORRENTS_DIR} [OK]
	cp -R ${CUSTOM_TRANSMISSION_TORRENTS_DIR} ${DEFAULT_TRANSMISSION_TORRENTS_DIR}

	# -- Adjust proper permissions on transmission directory
	chown -R transmission:transmission /var/lib/transmission

	# -- Restore nginx.conf
	printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_NGINX_CONF} [OK]
	cp ${CUSTOM_NGINX_CONF} ${DEFAULT_NGINX_CONF}

	# -- Restore nginx backends.conf
	printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_NGINX_BACKENDS} [OK]
	cp ${CUSTOM_NGINX_BACKENDS} ${DEFAULT_NGINX_BACKENDS}

	# -- Restore nginx proxy.conf
	printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_NGINX_PROXY} [OK]
	cp ${CUSTOM_NGINX_PROXY} ${DEFAULT_NGINX_PROXY}

	# -- Restore smb.conf
	printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_SAMBA_CONF} [OK]
	cp ${CUSTOM_SAMBA_CONF} ${DEFAULT_SAMBA_CONF}

	# -- Restore vsftp.conf
	printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_VSFTPD_CONF} [OK]
	cp ${CUSTOM_VSFTPD_CONF} ${DEFAULT_VSFTPD_CONF}

	# -- Restore iptables-rules
	printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_IPTABLES_RULES} [OK]
	cp ${CUSTOM_IPTABLES_RULES} ${DEFAULT_IPTABLES_RULES}

	# -- Restore .vimrc
	printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_VIM_CONF} [OK]
	cp ${CUSTOM_VIM_CONF} ${DEFAULT_VIM_CONF}

	# -- Restore sshd.conf
	printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_SSHD_CONF} [OK]
	cp ${CUSTOM_SSHD_CONF} ${DEFAULT_SSHD_CONF}

	# -- Restore cronjobs
	printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_ROOT_CRONJOBS} [OK]
	cp ${CUSTOM_ROOT_CRONJOBS} ${DEFAULT_ROOT_CRONJOBS}

	# # -- Restore plex-media-server preferences.xml
	# printf "${BLUE}%-75s${END_COLOR} ${GREEN}%s${END_COLOR}\n" ${CUSTOM_PLEX_PREFERENCES} [OK]
	# cp ${CUSTOM_PLEX_PREFERENCES} "${DEFAULT_PLEX_PREFERENCES}"


}

# -- Enable services at boot but don't start them
function services {

	
	printf "\n${YELLOW}\t- Stop running services and enable them at boot -${END_COLOR}\n\n"

	# -- transmission-daemon
	SERVICE_TRANSMISSION_CHECK=$(ps -ef | grep -v grep | grep transmission-daemon)

	if [ $? != 0 ]; then
		printf "${BLUE}%-70s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* transmission-daemon" [ENABLED]	
		systemctl enable transmission-daemon &> /dev/null
	else
		printf "${BLUE}%-70s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* transmission-daemon" [ENABLED]
		systemctl stop transmission-daemon &> /dev/null
		systemctl enable transmission-daemon &> /dev/null
	fi


	# -- nginx
	SERVICE_NGINX_CHECK=$(ps -ef | grep -v grep | grep nginx)

	if [ $? != 0 ]; then
		printf "${BLUE}%-70s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* nginx" [ENABLED]	
		systemctl enable nginx &> /dev/null
	else
		printf "${BLUE}%-70s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* nginx" [ENABLED]
		systemctl stop nginx &> /dev/null
		systemctl enable nginx &> /dev/null
	fi

	# -- vsftp
	SERVICE_VSFTPD_CHECK=$(ps -ef | grep -v grep | grep vsftpd)

	if [ $? != 0 ]; then
		printf "${BLUE}%-70s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* vsftpd" [ENABLED]	
		systemctl enable vsftpd &> /dev/null
	else
		printf "${BLUE}%-70s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* vsftpd" [ENABLED]
		systemctl stop vsftpd &> /dev/null
		systemctl enable vsftpd &> /dev/null
	fi

	# -- PlexMediaServer
	SERVICE_PLEX_CHECK=$(ps -ef | grep -v grep | grep plexmediaserver)

	if [ $? != 0 ]; then
		printf "${BLUE}%-70s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* plexmediaserver" [ENABLED]	
		systemctl enable plexmediaserver &> /dev/null
	else
		printf "${BLUE}%-70s${END_COLOR} ${GREEN}%s${END_COLOR}\n" "* plexmediaserver" [ENABLED]
		systemctl stop plexmediaserver &> /dev/null
		systemctl enable plexmediaserver &> /dev/null
	fi
	

}

function run_checks {

	printf "\n${YELLOW}\t- Check and install missing components -${END_COLOR}\n\n"

	check_epel
	check_transmission_daemon
	check_nginx
	check_samba
	check_vsftpd
	check_wget
	check_iptables
	check_vim
	grab_plex

}

# ---------------------------------------------------------------------------------------- #
# -- Check and install missing components
printf '%80s\n' | tr ' ' -
run_checks

# -- Create backups of the original files
printf '%80s\n' | tr ' ' -
backup_initial_configs

# -- Stop services and enable them at boot
printf '%80s\n' | tr ' ' -
services

# -- Copy custom configuration files
printf '%80s\n' | tr ' ' -
copy_custom_config

printf '%80s\n' | tr ' ' -