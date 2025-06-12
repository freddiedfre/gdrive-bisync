# gdrive-bisync

A cross-platform Bash utility to safely two-way sync a local folder with Google Drive using `rclone bisync`.

## Features

- Cross-platform support (Linux, Ubuntu, macOS, Windows with WSL)
- Installs the latest stable version of `rclone`
- Secure Google Drive authentication
- Initialize and teardown folder sync mappings
- Perform on-demand and forced two-way syncs
- Optional cron job integration for periodic syncing
- Modular Bash scripts with man-style help output

## Requirements

- `bash` shell
- `curl` (for installer)
- `cron` (for automatic scheduling, optional)

## Installation

```bash
git clone https://github.com/yourusername/gdrive-bisync.git
cd gdrive-bisync
chmod +x scripts/gdrive-bisync.sh
./scripts/gdrive-bisync.sh install
```

## Usage

```bash
./scripts/gdrive-bisync.sh <command> [options]
```

### Commands

- `install` — Install the latest stable version of rclone
- `auth` — Securely authenticate and configure rclone with Google Drive
- `setup <local> <remote>` — Setup sync mapping between a local folder and remote folder
- `sync` — Run a one-time, two-way synchronization
- `resync` — Force a full resync and recreate sync state
- `teardown` — Delete the sync metadata and remove mappings
- `cron-enable <schedule>` — Add a cron job (e.g. `"*/15 * * * *"`)
- `cron-disable` — Remove the cron job
- `help` — Show command help

### Example

```bash
# Inital rclone installation
./scripts/gdrive-bisync.sh install

# Inital rclone authentication
./scripts/gdrive-bisync.sh auth

# One-time setup
./gdrive-bisync.sh setup my-rclone-remote-host path-to-local-folder path-to-hosted-folder

# Regular sync
./scripts/gdrive-bisync.sh sync my-rclone-remote-host path-to-local-folder path-to-hosted-folder

# Resync if things are broken
./scripts/gdrive-bisync.sh resync my-rclone-remote-host path-to-local-folder path-to-hosted-folder

# Enable sync every 15 minutes
./scripts/gdrive-bisync.sh cron-enable "*/15 * * * *" my-rclone-remote-host path-to-local-folder path-to-hosted-folder

```

## File Structure

```text
gdrive-bisync/
├── scripts/
│   └── gdrive-bisync.sh      # Main utility script
├── docs/
│   └── manpages.md           # Optional manual reference and details
├── README.md                 # Project usage and documentation
├── LICENSE                   # MIT License (or your preferred license)
```

## License

MIT License

## Acknowledgements

- [rclone](https://rclone.org) for sync engine

---

Feel free to fork or contribute! PRs are welcome.
