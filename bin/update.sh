#!/bin/bash

# setup colors
red=`tput setaf 1`
green=`tput setaf 2`
cyan=`tput setaf 6`
bold=`tput bold`
reset=`tput sgr0`

heading()
{
	echo
	echo "${cyan}==>${reset}${bold} $1${reset}"
}

success()
{
	echo
	echo "${green}==>${bold} $1${reset}"
}

error()
{
	echo
	echo "${red}==>${bold} Error: $1${reset}"
}

heading "Updating vapory"

# figure out what we have to update
if [[ -f /usr/bin/gvap ]];
then
	vaptype="gvap"
	success "Found gvap"
else
	if [[ -f /usr/bin/vap ]];
	then
		vaptype="vap"
		success "Found vap"
	else
		error "Couldn't find vapory"
		exit 0
	fi
fi

heading "Stopping processes"
pm2 stop all

heading "Flushing logs"
pm2 flush
rm -Rf ~/logs/*
rm -rf ~/.local/share/Trash/*

heading "Stopping pm2"
pm2 kill

heading "Killing remaining node processes"
echo `ps auxww | grep node | awk '{print $2}'`
kill -9 `ps auxww | grep node | awk '{print $2}'`

heading "Removing vapory"
sudo apt-get remove -y $vaptype

heading "Updating repos"
sudo apt-get clean
sudo add-apt-repository -y ppa:vapory/vapory
sudo add-apt-repository -y ppa:vapory/vapory-dev
sudo apt-get update -y
sudo apt-get upgrade -y

heading "Installing vapory"
sudo apt-get install -y $vaptype

heading "Updating vap-netstats client"
cd ~/bin/www
git pull
sudo npm update
cd ..

success "Vapory was updated successfully"

heading "Restarting processes"
pm2 start processes.json
