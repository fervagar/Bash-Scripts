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

## Do a backup of an entire disk and save it into a compressed file
## See other script "restore_image.sh"

DEVICE="";
BDIR="";

if [ ! -n "$BASH_VERSION" ]; then
	echo "Please run this script in a BASH shell (i.e: ./$0)"
	exit 1;
fi;

if [ $# -ne 2 ]; then
	echo "usage: $0 device backupDirectory" 1>&2;
	exit 1;
fi;

DEVICE="$1";
CDIR="$(pwd)";
BFILE="$2/backup_$(date +%d%m%y).gz";

## Chech if pv is installed
if [ $(which pv | wc -l) -eq 0 ]; then
	echo "Sorry... The program 'pv' is not installed :(";
	exit 1;
fi;

read -p "Are you sure to backup the device '$DEVICE' onto the file $BFILE? (y/n) " -n 1 -r;
echo;

if [[ $REPLY =~ ^[Yy]$ ]]; then
	sudo su - root -c 'cd "$0"; dd bs=4M if="$1" | pv | gzip > "$2";' -- $CDIR $DEVICE $BFILE;
fi;
