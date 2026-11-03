#!/bin/bash

set -e

clear

echo
echo "========================================"
echo "        MadOS Build System"
echo "========================================"
echo

PROJECTS=(
    "mados_core"
    "mados-update"
    "mados-welcome"
)

for project in "${PROJECTS[@]}"
do

    echo
    echo "▶ Building $project"
    echo

    (
        cd "$project"
        chmod +x build.sh
        ./build.sh
    )

done

echo
echo "========================================"
echo "✓ MadOS Build Complete"
echo "========================================"
