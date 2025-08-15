#!/usr/bin/env bats
load "helper"

function setup() {
  common_setup
}

function teardown() {
  common_teardown
}

@test "back up a directory" {
  cat << 'EOF' > backup
#!/usr/bin/env bash
set -e

echo "@@@@@@@@@@@ pwd from backup script: '${PWD}'"
echo "Hello, World!" > hello.txt
EOF

  chmod 755 backup

  mkdir -p .config/rclone
  cat << 'EOF' > .config/rclone/rclone.conf
[dest]
type = local
EOF

  mkdir target

  export BACLIUP_BACKUP_SCRIPT="${PWD}/backup"
  export BACLIUP_BACKUP_TO=dest:target
  export BACLIUP_GPG_RECIPIENT="Bacliup (Test) <bacliup@alphahydrae.dev>"

  run bacliup
  assert_success

  backup_file="$(ls -1 target|head -n 1)"
  mkdir result
  echo '@@@@@@@@@@@@@@@'
  ls -la target
  echo '@@@@@@@@@@@@@@@'
  echo "$PATH"
  echo '@@@@@@@@@@@@@@@'
  which gpg
  echo '@@@@@@@@@@@@@@@'
  echo "'$(cat "target/${backup_file}")'"
  echo '@@@@@@@@@@@@@@@'
  cat "target/${backup_file}" | fake_gpg_decrypt > result/decrypted.tar

  cd result
  tar -xf decrypted.tar
  backup_directory="$(echo "$backup_file"|sed 's/\.tar\.gpg$//')"
  test -d "$backup_directory"
  test -f "${backup_directory}/hello.txt"
  assert_equal "$(cat "${backup_directory}/hello.txt")" "Hello, World!"
}

@test "bacliup fails if it cannot find the backup script" {
  run bacliup
  assert_failure 100
  assert_output "Backup script /usr/local/bin/backup does not exist"
}

@test "bacliup fails if the backup script is not a file" {
  mkdir foo
  export BACLIUP_BACKUP_SCRIPT=./foo
  run bacliup
  assert_failure 101
  assert_output "Backup script ./foo is not a file"
}

@test "bacliup fails if the backup script is not executable" {
  touch foo
  export BACLIUP_BACKUP_SCRIPT=./foo
  run bacliup
  assert_failure 102
  assert_output "Backup script ./foo is not executable"
}
