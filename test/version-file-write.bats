#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RENV_TEST_DIR"
  cd "$RENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run renv-version-file-write
  assert_failure "Usage: renv version-file-write <file> <version>"
  run renv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".R-version" ]
  run renv-version-file-write ".R-version" "2.7.6"
  assert_failure "renv: version \`2.7.6' not installed"
  assert [ ! -e ".R-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${RENV_ROOT}/versions/2.7.6"
  assert [ ! -e "my-version" ]
  run renv-version-file-write "${PWD}/my-version" "2.7.6"
  assert_success ""
  assert [ "$(cat my-version)" = "2.7.6" ]
}
