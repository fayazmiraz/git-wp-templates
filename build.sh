#!/bin/bash

SCRIPT_ROOT=$( cd "$(dirname "$0")"; PWD -P )
repos=( "dev" "hub" "live" )
FUNC_DIR="$SCRIPT_ROOT/.gwp"
REPO_FUNC_DIR="gwp"

for repo in "${repos[@]}"
do
    cp -af "$SCRIPT_ROOT/gwp.conf" "$SCRIPT_ROOT/$repo/hooks/gwp.conf"
    if [[ $? -ne 0 ]]; then
        echo "Error: couldn't copy config file in path: [$SCRIPT_ROOT/$repo/hooks/gwp.conf]" 1>&2
        exit 0
    fi
    if [[ ! -d "$SCRIPT_ROOT/$repo/hooks/$REPO_FUNC_DIR" ]]; then
        $( cd "$SCRIPT_ROOT/$repo/hooks" && mkdir "$REPO_FUNC_DIR" )
        if [[ $? -ne 0 ]]; then
            echo "Error: couldn't create directory: [$REPO_FUNC_DIR] in path: [$SCRIPT_ROOT/$repo/hooks]" 1>&2
            exit 0
        fi
    fi
done

find "${FUNC_DIR}"/* -print0 2>/dev/null | while IFS= read -r -d '' func
do
    if [[ -f "$func" ]]; then
        file_name=$( basename "$func" )

        for repo in "${repos[@]}"
        do
            cpy=""
            case "$repo" in
                "dev" )
                    cpy="true"; ;;
                "hub" )
                    cpy="true"; ;;
                "live" )
                    case "$file_name" in
                        "error_exit"|"warn") cpy="true"; ;;
                    esac
                    ;;
            esac
            if [[ ! -z "$cpy" ]]; then
                cp -af "$func" "$SCRIPT_ROOT/$repo/hooks/$REPO_FUNC_DIR/$file_name"
            fi
        done
    fi
done