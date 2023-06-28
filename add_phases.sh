#!/bin/bash

DEFAULT_DICT=array30_phrases.dict.yaml
CUSTOM_DICT=array30_phrases_custom.dict.yaml

# read_yes_no()
# Ask for yes/no answer
#
# $1: string to prompt
# return: true if user input is positive
#         false if user input if negative
function read_yes_no() {
    local option
    while [[ "$option" != "y" && "$option" != "n" ]]; do
        echo -n "$1 (y/n) "
        read option

        if [[ "$option" == "y" ]]; then
            return 0
        elif [[ "$option" == "n" ]]; then
            return 1
        fi
    done
}

##################
# Main
#################

for file in "$DEFAULT_DICT" "$CUSTOM_DICT"; do
    if [[ ! -f "$file" ]]; then
        echo "$file not found"
        exit 1
    fi
done

while true; do

    # Ask for the phase to insert
    unset phase
    while [[ -z $phase ]]; do
        echo -n "Enter the phase: "
        read phase
    done

    # Check if the phase exist
    phase_check_default=$(sed '1,/#Phase\tcode/d' $DEFAULT_DICT | grep "$phase")
    phase_check_custom=$(sed '1,/#Phase\tcode/d' $CUSTOM_DICT | grep "$phase")

    if [[ -n "$phase_check_default" || -n "$phase_check_custom" ]]; then
        echo "Possible duplicated entry found!"
        [[ -n "$phase_check_default" ]] && echo -e "In $DEFAULT_DICT:\n$phase_check_default"
        [[ -n "$phase_check_custom" ]] && echo -e "In $CUSTOM_DICT:\n$phase_check_custom"

        read_yes_no "Still proceed?"

        if [[ $? -ne 0 ]]; then
            # Ask for another phase again
            continue
        fi
    fi

    # Ask for the code
	# TODO: search for possible code automatically
    unset code
    while [[ -z $code ]]; do
        echo -n "Enter the code: "
        read code
    done

    # Confirmation
    echo "Phase: $phase | Code: $code"
    read_yes_no "Insert?"
    echo $?

    if [[ $? -eq 0 ]]; then
        # insert the phase
        echo "$phase	$code" >> $CUSTOM_DICT
		echo "Phase inserted"
	else
		continue
	fi
done

