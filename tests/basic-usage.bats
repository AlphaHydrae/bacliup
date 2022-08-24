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
