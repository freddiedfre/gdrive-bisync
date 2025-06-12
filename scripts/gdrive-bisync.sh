#!/bin/bash

# gdrive-bisync: A utility for two-way syncing local and Google Drive folders using rclone bisync.

set -e

REPO_DIR="$(dirname "$0")"
CONFIG_DIR="$HOME/.config/rclone"

show_help() {
    cat << EOF
Usage: gdrive-bisync.sh <command> [options]

Commands:
  install                               Install latest stable rclone
  auth                                  Run rclone config auth flow
  setup <remote> <local> <remote_dir>   Setup folder mapping and initialize bisync
  sync <remote> <local> <remote_dir>    Perform a two-way sync
  resync <remote> <local> <remote_dir>  Force resync and rebuild state
  teardown <local>                      Remove sync config/state
  cron-enable "<schedule>" <remote> <local> <remote_dir>  Schedule sync via cron
  cron-disable                          Remove sync cron job
  help                                  Show this help message
EOF
}

install_rclone() {
    echo "Installing latest stable rclone..."
    curl https://rclone.org/install.sh | sudo bash
    echo "rclone installed successfully."
}

auth_rclone() {
    echo "Starting rclone configuration for Google Drive..."
    rclone config
}

setup_sync() {
    local RCLONE_REMOTE="$1"
    local LOCAL_DIR="$2"
    local REMOTE_DIR="$3"

    if [[ -z "$RCLONE_REMOTE" || -z "$LOCAL_DIR" || -z "$REMOTE_DIR" ]]; then
        echo "Error: You must specify remote, local, and remote directory."
        exit 1
    fi

    mkdir -p "$LOCAL_DIR"
    echo "Initializing full hierarchy bisync between $LOCAL_DIR and $RCLONE_REMOTE:$REMOTE_DIR..."
    rclone bisync "$LOCAL_DIR" "$RCLONE_REMOTE:$REMOTE_DIR" --resync
    echo "Setup complete."
}

run_sync() {
    local RCLONE_REMOTE="$1"
    local LOCAL_DIR="$2"
    local REMOTE_DIR="$3"

    if [[ -z "$RCLONE_REMOTE" || -z "$LOCAL_DIR" || -z "$REMOTE_DIR" ]]; then
        echo "Error: You must specify remote, local, and remote directory."
        exit 1
    fi

    echo "Performing recursive bisync of full directory structure..."
    rclone bisync "$LOCAL_DIR" "$RCLONE_REMOTE:$REMOTE_DIR" --log-level INFO

}

force_resync() {
    local RCLONE_REMOTE="$1"
    local LOCAL_DIR="$2"
    local REMOTE_DIR="$3"

    if [[ -z "$RCLONE_REMOTE" || -z "$LOCAL_DIR" || -z "$REMOTE_DIR" ]]; then
        echo "Error: You must specify remote, local, and remote directory."
        exit 1
    fi

    echo "Forcing full hierarchy resync (clearing state)..."
    rclone bisync "$LOCAL_DIR" "$RCLONE_REMOTE:$REMOTE_DIR" --resync
    echo "Resync complete."
    echo "Resync complete."
}

teardown_sync() {
    local LOCAL_DIR="$1"

    if [[ -z "$LOCAL_DIR" ]]; then
        echo "Error: You must specify the local directory."
        exit 1
    fi

    echo "Tearing down bisync state..."
    rm -rf "$LOCAL_DIR/.rclone"
    echo "Sync state removed."
}

cron_enable() {
    local SCHEDULE="$1"
    local RCLONE_REMOTE="$2"
    local LOCAL_DIR="$3"
    local REMOTE_DIR="$4"

    if [[ -z "$SCHEDULE" || -z "$RCLONE_REMOTE" || -z "$LOCAL_DIR" || -z "$REMOTE_DIR" ]]; then
        echo "Error: You must provide schedule, remote, local, and remote_dir."
        exit 1
    fi

    local CMD="rclone bisync \"$LOCAL_DIR\" \"$RCLONE_REMOTE:$REMOTE_DIR\" --log-level INFO --log-file=$HOME/rclone-cron.log"
    (crontab -l 2>/dev/null; echo "$SCHEDULE $CMD") | crontab -
    echo "Cron job added for recursive bisync."
}

cron_disable() {
    crontab -l | grep -v "rclone bisync" | crontab -
    echo "Cron job removed."
}

case "$1" in
    install)
        install_rclone
        ;;
    auth)
        auth_rclone
        ;;
    setup)
        setup_sync "$2" "$3" "$4"
        ;;
    sync)
        run_sync "$2" "$3" "$4"
        ;;
    resync)
        force_resync "$2" "$3" "$4"
        ;;
    teardown)
        teardown_sync "$2"
        ;;
    cron-enable)
        cron_enable "$2" "$3" "$4" "$5"
        ;;
    cron-disable)
        cron_disable
        ;;
    help|*)
        show_help
        ;;
esac
