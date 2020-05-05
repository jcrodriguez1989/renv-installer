#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run renv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${RENV_ROOT}/shims"
  touch "${RENV_ROOT}/shims/R"
  touch "${RENV_ROOT}/shims/irb"
  run renv-shims
  assert_success
  assert_line "${RENV_ROOT}/shims/R"
  assert_line "${RENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${RENV_ROOT}/shims"
  touch "${RENV_ROOT}/shims/R"
  touch "${RENV_ROOT}/shims/irb"
  run renv-shims --short
  assert_success
  assert_line "irb"
  assert_line "R"
}
