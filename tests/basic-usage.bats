#!/usr/bin/env bats
load "helper"

function setup() {
  common_setup
}

function teardown() {
  common_teardown
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
