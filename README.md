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
