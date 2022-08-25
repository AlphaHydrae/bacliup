# Bacliup

> **A command-line backup solution based on Bash, cron & rclone, _for when shell
> scripting is good enough_. Also comes with a Docker image.**

* Back up anything you can access from a [Bash][bash] script, using [tar][tar],
  [gzip][gzip] and [GnuPG][gnupg] to create, compress and encrypt archives.
* Easy periodic backups with [Cron][cron].
* Local/remote backup storage with [rclone][rclone] to [any supported
  provider][rclone-providers].
* Success/failure notifications with [Slack][slack] (using [curl][curl] and
  [jq][jq] for the integration).



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
