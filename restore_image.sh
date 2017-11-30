#!/bin/bash

#################################################################################
#### Copyright (C) 2017 Fernando Vañó García                                    #
####                                                                            #
####    This program is free software; you can redistribute it and/or modify    #
####    it under the terms of the GNU General Public License as published by    #
####    the Free Software Foundation; either version 2 of the License, or       #
####    (at your option) any later version.                                     #
####                                                                            #
####    This program is distributed in the hope that it will be useful,         #
####    but WITHOUT ANY WARRANTY; without even the implied warranty of          #
####    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
####    GNU General Public License for more details.                            #
####                                                                            #
####    You should have received a copy of the GNU General Public License along #
####    with this program; if not, write to the Free Software Foundation, Inc., #
####    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.             #
####                                                                            #
####    Fernando Vanyo Garcia <fernando@fervagar.com>                           #
####                                                                            #
#################################################################################

## Restore a previously saved backup image into a disk
## See other script "backup_image.sh"

IMAGE="";
DEVICE="";

if [ ! -n "$BASH_VERSION" ]; then
	echo "Please run this script in a BASH shell (i.e: ./$0)"
	exit 1;
fi;

if [ $# -ne 2 ]; then
	echo "usage: $0 image device " 1>&2;
	exit 1;
fi;

IMAGE="$1";
DEVICE="$2";
CDIR="$(pwd)";

## Chech if pv is installed
if [ $(which pv | wc -l) -eq 0 ]; then
	echo "Sorry... The program 'pv' is not installed :(";
	exit 1;
fi;

read -p "Are you sure to restore the image file '$IMAGE' onto the device '$DEVICE'? (y/n) " -n 1 -r;
echo;

if [[ $REPLY =~ ^[Yy]$ ]]; then
	sudo su - root -c 'cd "$0"; gzip -dc "$1" | pv | dd bs=4M of="$2";' -- $CDIR $IMAGE $DEVICE;
fi;
