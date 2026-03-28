#!/bin/bash
# envycontrol-switch.sh
# Called by the plasmoid to switch GPU mode.
# Usage: envycontrol-switch.sh <mode>
# mode: integrated | nvidia | hybrid

MODE="$1"

if [[ "$MODE" != "integrated" && "$MODE" != "nvidia" && "$MODE" != "hybrid" ]]; then
    echo "Invalid mode: $MODE" >&2
    exit 1
fi

envycontrol -s "$MODE"
STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo "Success"
else
    echo "Failed" >&2
    exit $STATUS
fi
