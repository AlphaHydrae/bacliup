# Bacliup

> **A backup solution based on Bash, cron & rclone, _for when the command line
> is good enough_, Docker included :tada:**

[![build](https://github.com/AlphaHydrae/bacliup/actions/workflows/build.yml/badge.svg)](https://github.com/AlphaHydrae/bacliup/actions/workflows/build.yml)
[![license](https://img.shields.io/github/license/AlphaHydrae/bacliup)](https://opensource.org/licenses/MIT)

* Back up anything you can access from a [Bash][bash] script, using [tar][tar],
  [gzip][gzip] and [GnuPG][gnupg] to create, compress and encrypt archives.
* Easy periodic backups with [Cron][cron].
* Local/remote backup storage with [rclone][rclone] to [any supported
  provider][rclone-providers].
* Success/failure notifications with [Slack][slack] (using [curl][curl] and
  [jq][jq] for the integration).

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Usage](#usage)
- [How it works](#how-it-works)
- [Configuration](#configuration)
  - [Backup configuration files](#backup-configuration-files)
  - [Command line arguments & environment variables](#command-line-arguments--environment-variables)
  - [Auto-import GPG encryption key](#auto-import-gpg-encryption-key)
  - [Slack notifications](#slack-notifications)
  - [Additional configuration](#additional-configuration)
- [Exit codes](#exit-codes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Usage

```bash
# With the necessary environment variables and configuration files
bacliup

# By hand
bacliup --name my-backup --to dest: --script /usr/local/bin/backup --gpg-recipient "John Doe <john.doe@example.com>"
```

Bacliup will store a file named `my-backup.20010203T040506Z.tar.gpg` to the
specified Rclone destination (where `20010203T040506Z` is the valid ISO-8601
date and time at which that backup was created).

> [!TIP]
> Bacliup assumes that you have already configured Rclone. In these examples, a
> `dest` Rclone remote must be configured.

You can also configure cron to run your backups on a schedule:

```bash
bacliup init
```

> [!TIP]
> This requires you to create some Bacliup-specific [backup configuration
> files](#backup-configuration-files).

## How it works

When running, bacliup goes through this process:

* A temporary directory is created to store backup files in. This directory will
  be deleted when Bacliup exits.
* An arbitrary backup script provided by you is executed.

  It's up to you to copy whatever you want (files, database dumps, etc) in the
  current working directory (also available as the `$BACKUP_DIR` environment
  variable).
* The temporary directory is archived with [tar][tar].
* The archive is compressed with [gzip][gzip].
* The compressed archive is encrypted with [GnuPG][gnupg].
* The encrypted backup is copied/uploaded to the [rclone][rclone] destination
  you have configured.

> [!IMPORTANT]
> You will need enough storage space for whatever uncompressed backups you put
> in the temporary directory. The archival, compression, encryption and upload
> happens in memory in a single Unix pipeline without storing any additional
> data on disk.

## Configuration

You can configure Bacliup in two ways:

- Entirely from environment variables and command line arguments.
- From backup configuration files (only some configuration options are supported
  for now).

### Backup configuration files

When you run Bacliup with a backup "type" like so:

```bash
bacliup hourly
```

Bacliup will look for an `hourly` configuration file (in the
`/etc/bacliup/backups` directory by default). This file is expected to have the
following format:

```
to dest:hourly/my-backup/
cron 0 * * * *
```

The available backup configuration file keys are:

| Key    | Default value | Description                                                                                                |
| `to`   | `dest:`       | Rclone destination to store the backup to (in the format `remote:path` where `remote` is an Rclone remote) |
| `cron` | -             | Optional cron schedule to set up for this backup type when configuring cron with `bacliup init`            |

### Command line arguments & environment variables

These are the main configuration options for Bacliup:

| Environment variable          | Command line                | Default value           | Description                                                                                                 |
| :---------------------------- | :-------------------------- | :---------------------- | :---------------------------------------------------------------------------------------------------------- |
| `$BACLIUP_BACKUP_TYPE`        | _(optional) first argument_ | `default`               | Type of backup (determines which backup configuration file is read if you are using them)                   |
| `$BACLIUP_BACKUP_NAME`        | `-n`, `--name`              | `backup`                | Name of the backup (becomes part of the backup file name)                                                   |
| `$BACLIUP_BACKUP_CONFIGS_DIR` | -                           | `/etc/bacliup/backups`  | Directory containing the backup configurations                                                              |
| `$BACLIUP_BACKUP_SCRIPT`      | `-s`, `--script`            | `/usr/local/bin/backup` | Arbitrary script that will perform the actual backup                                                        |
| `$BACLIUP_BACKUP_TO`          | `-t`, `--to`                | `dest:`                 | Rclone destination to store the backup to (in the format `remote:path`, where `remote` is an Rclone remote) |
| `$BACLIUP_GPG_RECIPIENT`      | `-r`, `--gpg-recipient`     | -                       | Comma-separated GPG recipients for backup encryption                                                        |

### Auto-import GPG encryption key

You can set the following environment variables to have Bacliup automatically
import a GPG public key before performing the backup. The key will also be
configured for ultimate trust.

| Environment variable         | Default value | Description                                    |
| :--------------------------- | :------------ | :--------------------------------------------- |
| `$BACLIUP_GPG_IMPORT_KEY`    | -             | GPG public key to import for backup encryption |
| `$BACLIUP_GPG_IMPORT_KEY_ID` | -             | ID of the GPG public key for backup encryption |

### Slack notifications

You can configure backup success notifications in Slack with the following
options:

| Environment variable          | Default value            | Description                                                                                      |
| :---------------------------- | :----------------------- | :----------------------------------------------------------------------------------------------- |
| `$BACLIUP_SLACK_WEBHOOK`      | -                        | Slack webhook URL to send backup success notifications                                           |
| `$BACLIUP_TEMPLATES_DIR`      | `../templates`           | Directory containing the JSON templates for Slack notifications (relative to the Bacliup script) |

### Additional configuration

These other configuration options are also provided:

| Environment variable          | Default value            | Description                                                                 |
| :---------------------------- | :----------------------- | :-------------------------------------------------------------------------- |
| `$BACLIUP_CURL_BIN`           | `curl`                   | Path to the `curl` command                                                  |
| `$BACLIUP_GPG_BIN`            | `gpg`                    | Path to the `gpg` command                                                   |
| `$BACLIUP_RCLONE_BIN`         | `rclone`                 | Path to the `rclone` command                                                |
| `$BACLIUP_TAR_BIN`            | `tar`                    | Path to the `tar` command                                                   |
| `$BACLIUP_CRON_SCRIPT`        | `/usr/local/bin/bacliup` | Path to Bacliup when configuring cron                                       |
| `$BACLIUP_RCLONE_CONFIG_FILE` | -                        | Custom path to an Rclone configuration file (if not using the default path) |

## Exit codes

Bacliup will exit with the following codes when known errors occur:

| Code | Description                                                                                                    |
| :--- | :------------------------------------------------------------------------------------------------------------- |
| 1    | An unexpected error occurred.                                                                                  |
| 2    | A required argument is missing.                                                                                |
| 3    | A provided argument is invalid.                                                                                |
| 4    | Unsupported extra arguments were provided.                                                                     |
| 100  | The backup script specified with `$BACLIUP_BACKUP_SCRIPT` does not exist.                                      |
| 101  | The backup script specified with `$BACLIUP_BACKUP_SCRIPT` is not a file.                                       |
| 102  | The backup script specified with `$BACLIUP_BACKUP_SCRIPT` is not executable.                                   |
| 103  | The Rclone configuration file specified with `$BACLIUP_RCLONE_CONFIG_FILE` does not exist.                     |
| 104  | The Rclone configuration file specified with `$BACLIUP_RCLONE_CONFIG_FILE` is not a file.                      |
| 105  | The Rclone configuration file specified with `$BACLIUP_RCLONE_CONFIG_FILE` is not readable.                    |
| 140  | One of the GPG recipients specified with `$BACLIUP_GPG_RECIPIENT` cannot be found.                             |
| 141  | The GPG key provided with `$BACLIUP_GPG_IMPORT_KEY` could not be imported.                                     |
| 142  | The GPG key provided with `$BACLIUP_GPG_IMPORT_KEY` could not be trusted.                                      |
| 160  | The configured backup destination is not a valid rclone path (e.g. `dest:path`).                               |
| 161  | The remote storage specified in the configured backup destination cannot be found in the rclone configuration. |



[bash]: https://www.gnu.org/software/bash/
[cron]: https://en.wikipedia.org/wiki/Cron
[curl]: https://curl.se
[gnupg]: https://gnupg.org
[gzip]: https://www.gnu.org/software/gzip/
[jq]: https://stedolan.github.io/jq/
[rclone]: https://rclone.org
[rclone-providers]: https://rclone.org/#providers
[slack]: https://slack.com
[tar]: https://www.gnu.org/software/tar/
