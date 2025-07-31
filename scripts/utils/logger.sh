#!bash

print_time() {
    echo "[$(date +%H:%M:%S)]"
}

function echo_colour() {
    COLOUR='\033[1;34m'
    DEFAULT='\033[0m'

    echo -e "$(print_time) ${COLOUR}$1${DEFAULT}"
}

function echo_green() {
    COLOUR='\033[0;32m'
    DEFAULT='\033[0m'

    echo -e "$(print_time) ${COLOUR}$1${DEFAULT}"
}
