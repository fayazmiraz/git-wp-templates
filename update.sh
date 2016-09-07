#!/bin/bash

# ---- @usage:
# 1. first setup templateDir ( needed only once )
# git config init.templateDir PATH_TO_Git_WP_TEMPLATE
# 
# 2. Run the update script:
# git gwp-update
# [or]
# git gwpu


# ---- Global variables
PROG_NAME=$(basename $0)
UPDATE_BASE_PATH=$( cd "$(dirname "$0")"; PWD -P )
TEMPLATE_PATH=$(git config --path --get init.templateDir)
TEMPLATE_NAME=$(git config gitWPTemplate.name)
UPDATE_OPTIONS="$@"


# ---- Template dir / name check
if [[ ! -f "${TEMPLATE_PATH}/../update.sh" ]]; then
    TEMPLATE_PATH="${UPDATE_BASE_PATH}/${TEMPLATE_NAME}"
    if [[ ! -f "${TEMPLATE_PATH}/../update.sh" ]]; then
        echo " " 1>&2
        echo "Failed to recognize template directory. Please set init.templateDir as follows:" 1>&2
        echo " " 1>&2
        echo "$ git config init.templateDir ABSOLUTE_GIT_TEMPLATE_DIRECTORY" 1>&2
        echo " " 1>&2
        echo " " 1>&2
        echo "Then run the update script from git root directory using the command:" 1>&2
        echo "$ git updateGitWP" 1>&2
        echo " " 1>&2
        echo " " 1>&2
        echo "OR, set gitWPTemplate.name and run this script again:" 1>&2
        echo " " 1>&2
        echo "$ git config gitWPTemplate.name Git_WP_TEMPLATE_NAME" 1>&2
        echo " " 1>&2
        echo " " 1>&2
        echo "Aborting ${PROG_NAME} program." 1>&2
        echo " " 1>&2
        exit 1
    fi
fi


# ---- Update the template repo
$( cd "$UPDATE_BASE_PATH" && git pull 2>/dev/null )


# ---- Run the build script
$( cd "$UPDATE_BASE_PATH" && ./build.sh )

FUNC_DIR=".gwp"
# ---- include necessary functions
. "${TEMPLATE_PATH}/../$FUNC_DIR/error_exit" &&
. "${TEMPLATE_PATH}/../$FUNC_DIR/warn" &&
. "${TEMPLATE_PATH}/../$FUNC_DIR/response" &&
. "${TEMPLATE_PATH}/../.update/update_hooks"
if [[ $? -ne 0 ]]; then
    echo " " 1>&2
    echo "Failed to include necessary files! Aborting ${PROG_NAME} program." 1>&2
    echo " " 1>&2
    exit 1
fi


# ---- main function
main()
{

    # @todo check if it works even if git directory is customized outside of root dir
    # or renamed to something other than .git
    local git_dir=$( git rev-parse --git-dir )
    git_dir=$( realpath "$git_dir" )

    
    if [ ! -d "$git_dir" ]
    then
        error_exit "$LINENO: Run this script from the root of a git repository you want to update."
    fi

    echo " "
    echo "Updating git Template files ..."
    echo "------------------------------------------"
    echo "Source: [${TEMPLATE_PATH}]"
    echo "Destination: [${git_dir}]"
    echo "Options: [${UPDATE_OPTIONS}]"
    echo "------------------------------------------"
    echo " "
    cnt=$( response "Continue?" )
    if [[ "false" == "$cnt" ]]; then
        echo " "
        echo "You choose not to continue!"
        echo "Nothing is done this time. Program ${PROG_NAME} aborted."
        exit 0
    fi

    echo " "

    # copy files from src_dir to dest_dir and make them executable
    update_hooks "$TEMPLATE_PATH/hooks" "$git_dir/hooks"
}


main
exit 0