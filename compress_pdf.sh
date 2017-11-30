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

## This script tries to compress a PDF using Ghostscript. The merits of the Ghostscript command are
## for the user Tully in askubuntu.com: [20th May 2015]
##      https://askubuntu.com/questions/207447/how-to-reduce-the-size-of-a-pdf-file 
## I only wrapped it into an script for usability 

# Ghostscript binary
GS=gs

# ------------------------------------------------------------------------------------- #

# $1 <- command
function _check_cmd {
        [ ! $(which $1 | wc -c) -eq 0 ]
}

# $1 <- n bytes
function _byte_to_human {
        printf '%s' $(numfmt --to=iec-i --suffix=B --format="%.3f" $1)
}

# ------------------------------------------------------------------------------------- #

## Chech if GHOSTSCRIPT is installed
GHOSTSCRIPT=$(which ${GS})
if [ $(printf "${GHOSTSCRIPT}" | wc -c) -eq 0 ]; then
	echo "[-] Sorry... The program '${GS}' is not installed :("
	exit 1
fi

## Check the args
if [ $# -ne 2 ]; then
        echo "[!] Usage: $0 input.pdf output.pdf " 1>&2
        exit 1
fi

## Check INPUT 
INPUT=$1
if [ ! -e ${INPUT} ]; then
        echo "[-] '${INPUT}' does not exist"
        exit 1
fi

## Check OUTPUT
OUTPUT=$2
if [ -e ${OUTPUT} ]; then
        ## Check if INPUT is the same file as OUTPUT
        if [[ ${INPUT} -ef ${OUTPUT} ]]; then
                echo "[-] Input and Output are the same file"
                exit 1
        fi

        ## Follow symlink (if it's a symlink)
        if [ -L ${OUTPUT} ]; then OUTPUT=$(readlink ${OUTPUT}); fi

        ## Show warning
        read -p "The file '${OUTPUT}' will be overwritten. Are you sure? (y/N) " -n 1 -r;
        echo;

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "[-] Cancelled"
                exit 0
        fi
fi

echo "[+] Compressing '${INPUT}' -> '${OUTPUT}'"
${GHOSTSCRIPT}  -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/default \
                -dNOPAUSE -dQUIET -dBATCH -dDetectDuplicateImages \
                -dCompressFonts=true -r150 -sOutputFile=${OUTPUT} ${INPUT}

if ! _check_cmd stat; then
        ## Just exit without showing more info
        exit 0
fi

INPUT=$(stat --printf="%s" ${INPUT})
OUTPUT=$(stat --printf="%s" ${OUTPUT})

## 'stat' available
if ! _check_cmd numfmt; then
        # Show bytes
        echo "[+] Completed: ${INPUT} B -> ${OUTPUT} B"
        exit 0
fi

## 'numfmt' available
INPUT=$(_byte_to_human ${INPUT})
OUTPUT=$(_byte_to_human ${OUTPUT})
echo "[+] Completed: ${INPUT} -> ${OUTPUT}"

exit 0

