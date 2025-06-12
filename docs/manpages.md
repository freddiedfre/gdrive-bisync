# gdrive-bisync Manual Pages

## NAME

**gdrive-bisync** — Two-way sync utility between local folders and Google Drive using `rclone bisync`

## SYNOPSIS

**gdrive-bisync.sh** <command> \[options]

## DESCRIPTION

This script provides a safe, simple, and powerful interface to sync a local folder with a remote Google Drive folder using `rclone bisync`. It supports secure setup, on-demand syncing, full reinitialization, scheduled syncing via cron, and easy teardown.

## COMMANDS

### install

Installs the latest stable version of `rclone` on your system using the official install script.

**Usage:**

```bash
gdrive-bisync.sh install
```

### auth

Launches `rclone config` to set up and authorize access to your Google Drive.

**Usage:**

```bash
gdrive-bisync.sh auth
```

### setup

Initializes a bi-directional sync mapping between a local folder and a remote Google Drive path.
This command also performs a `--resync` operation to build the initial state.

**Usage:**

```bash
gdrive-bisync.sh setup <local_path> <remote_path>
```

**Example:**

```bash
gdrive-bisync.sh setup ~/Documents/myfolder mydrivefolder
```

### sync

Performs a regular two-way sync based on previous state. Only deltas are synced.

**Usage:**

```bash
gdrive-bisync.sh sync
```

### resync

Forces a full reinitialization of the sync state. This is useful if sync state is corrupted or inconsistent.

**Usage:**

```bash
gdrive-bisync.sh resync
```

### teardown

Removes the `.rclone` state folder used by `bisync`, effectively stopping future syncs unless reinitialized.

**Usage:**

```bash
gdrive-bisync.sh teardown
```

### cron-enable

Adds an automatic sync to your system cron scheduler.

**Usage:**

```bash
gdrive-bisync.sh cron-enable "*/30 * * * *"
```

### cron-disable

Removes the previously set cron job for syncing.

**Usage:**

```bash
gdrive-bisync.sh cron-disable
```

### help

Displays usage help for the script.

**Usage:**

```bash
gdrive-bisync.sh help
```

## NOTES

* This utility is stateless beyond the `.rclone` folder inside the local directory.
* Google Drive authentication tokens are stored securely in your `~/.config/rclone` directory.

## SEE ALSO

* `rclone bisync` documentation: [https://rclone.org/bisync/](https://rclone.org/bisync/)
* `cron` man page: `man 5 crontab`

## AUTHOR

Created by OpenAI's ChatGPT based on user specification.

## LICENSE

MIT License (see LICENSE file)
