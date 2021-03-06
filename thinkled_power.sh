#!/bin/bash

DEVICE_PATH=/sys/devices/platform/thinkpad_acpi/leds/tpacpi\:\:power
DEVICE=${DEVICE_PATH}/brightness
ITERATIONS=50
INTERVAL=.25

blink() {
    for ((i=1; i<="$ITERATIONS"; i++))
    do
        [[ -n "$VERBOSE" ]] && echo "ON $i / $ITERATIONS"
        echo "0" > $DEVICE
        [[ -n "$VERBOSE" ]] && echo "sleep $INTERVAL"
        sleep $INTERVAL
        [[ -n "$VERBOSE" ]] && echo "OFF $i / $ITERATIONS"
        echo "1" > $DEVICE
        [[ -n "$VERBOSE" ]] && echo "sleep $INTERVAL"
        sleep $INTERVAL
    done
}

log() {
    logger "$(basename $0) - Blinked $ITERATIONS times (interval: $INTERVAL)"
}

save_state() {
    SAVED_STATE=$(cat $DEVICE)
}

restore_state() {
    echo "$SAVED_STATE" > $DEVICE
}

[[ $EUID -ne 0 ]] && {
   echo "This script must be run as root" 1>&2
   exit 1
}

while getopts ":n:i:v" opt; do
    case $opt in
        n)
            [[ "$OPTARG" -eq "$OPTARG" && "$OPTARG" -gt 0 ]] && {
                ITERATIONS="$OPTARG"
            }
            ;;
        i)
            [[ "$OPTARG" -eq "$OPTARG" && "$OPTARG" -gt 0 ]] && {
                INTERVAL="$OPTARG"
                [[ "$INTERVAL" -gt 1000 ]] && {
                    let INTERVAL=INTERVAL/1000
                } || {
                    INTERVAL=".${INTERVAL}"
                }
            }
            ;;
        v)
            VERBOSE=1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done


cd "$DEVICE_PATH"
save_state
[[ -n $VERBOSE ]] && log
blink
restore_state