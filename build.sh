#!/bin/bash

set -e

echo
echo "========================================"
echo "      MadOS Build System"
echo "========================================"
echo

projects=(
    "mados_core"
    "mados-update"
    "mados-welcome"
)

for project in "${projects[@]}"
do
    echo
    echo "========================================"
    echo "Building $project"
    echo "========================================"

    cd "$project"

    chmod +x build.sh

    ./build.sh

    cd ..
done

echo
echo "========================================"
echo "✓ Everything Built Successfully"
echo "========================================"
