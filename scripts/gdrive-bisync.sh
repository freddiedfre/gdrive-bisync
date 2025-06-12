#!/bin/bash

# gdrive-bisync: A cross-platform utility for two-way syncing folders with Google Drive using rclone.
# Supports setup, teardown, on-demand sync, cron scheduling, and more.

set -e

REPO_DIR="$(dirname "$0")"
CONFIG_DIR="$HOME/.config/rclone"
RCLONE_REMOTE="gdrive"

show_help() {
    cat << EOF
Usage: gdrive-bisync.sh <command> [options]

Commands:
  install               Install latest stable rclone (cross-platform)
  auth                  Run secure authentication for Google Drive
  setup <local> <remote>  Setup folder mapping and initialize bisync
  sync                  Perform an on-demand two-way sync
  resync                Force resync and rebuild state
  teardown              Remove sync configuration and state
  cron-enable <schedule> Add syncing to cron (e.g. "*/30 * * * *")
  cron-disable          Remove cron job for syncing
  help                  Show this help message
EOF
}

install_rclone() {
    cat << EOF
install - Install the latest stable version of rclone.
This ensures compatibility with bisync and cloud support features.
EOF
    echo "Installing latest stable rclone..."
    curl https://rclone.org/install.sh | sudo bash
    echo "rclone installed successfully."
}

auth_rclone() {
    cat << EOF
auth - Launch secure authentication flow for Google Drive via rclone.
This allows rclone to access your Google Drive after OAuth approval.
EOF
    echo "Starting rclone configuration for Google Drive..."
    rclone config
}

setup_sync() {
    cat << EOF
setup - Initialize bisync mapping between local and remote folders.
Usage: setup <local_path> <remote_path>
EOF
    local LOCAL_DIR="$1"
    local REMOTE_DIR="$2"

    if [[ -z "$LOCAL_DIR" || -z "$REMOTE_DIR" ]]; then
        echo "Error: You must specify a local and remote folder."
        exit 1
    fi

    mkdir -p "$LOCAL_DIR"
    echo "Initializing bisync between $LOCAL_DIR and $RCLONE_REMOTE:$REMOTE_DIR..."
    rclone bisync "$LOCAL_DIR" "$RCLONE_REMOTE:$REMOTE_DIR" --resync
    echo "Setup complete."
}

run_sync() {
    cat << EOF
sync - Perform an on-demand two-way synchronization.
Runs rclone bisync with INFO logging.
EOF
    echo "Running bisync..."
    rclone bisync "$LOCAL_DIR" "$RCLONE_REMOTE:$REMOTE_DIR" --log-level INFO
}

force_resync() {
    cat << EOF
resync - Force reinitialization of sync state and scan changes again.
Useful for resolving state inconsistencies or missing files.
EOF
    echo "Forcing resync (may take time)..."
    rclone bisync "$LOCAL_DIR" "$RCLONE_REMOTE:$REMOTE_DIR" --resync
    echo "Resync complete."
}

teardown_sync() {
    cat << EOF
teardown - Removes the local rclone bisync state files.
Use this before remapping or cleaning a sync relationship.
EOF
    echo "Tearing down sync configuration..."
    rm -rf "$LOCAL_DIR/.rclone"
    echo "Sync state removed."
}

cron_enable() {
    cat << EOF
cron-enable - Add a cron job for automatic syncing.
Usage: cron-enable "<cron_schedule>"
Example: cron-enable "*/15 * * * *"
EOF
    local SCHEDULE="$1"
    if [[ -z "$SCHEDULE" ]]; then
        echo "Error: You must provide a cron schedule string."
        exit 1
    fi
    local CMD="rclone bisync \"$LOCAL_DIR\" \"$RCLONE_REMOTE:$REMOTE_DIR\" --log-level INFO --log-file=$HOME/rclone-cron.log"
    (crontab -l 2>/dev/null; echo "$SCHEDULE $CMD") | crontab -
    echo "Cron job added."
}

cron_disable() {
    cat << EOF
cron-disable - Remove the previously set rclone bisync cron job.
EOF
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
        setup_sync "$2" "$3"
        ;;
    sync)
        run_sync
        ;;
    resync)
        force_resync
        ;;
    teardown)
        teardown_sync
        ;;
    cron-enable)
        cron_enable "$2"
        ;;
    cron-disable)
        cron_disable
        ;;
    help|*)
        show_help
        ;;
esac
