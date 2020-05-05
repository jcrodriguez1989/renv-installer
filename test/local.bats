#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${RENV_TEST_DIR}/myproject"
  cd "${RENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.R-version" ]
  run renv-local
  assert_failure "renv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .R-version
  run renv-local
  assert_success "1.2.3"
}

@test "discovers version file in parent directory" {
  echo "1.2.3" > .R-version
  mkdir -p "subdir" && cd "subdir"
  run renv-local
  assert_success "1.2.3"
}

@test "ignores RENV_DIR" {
  echo "1.2.3" > .R-version
  mkdir -p "$HOME"
  echo "3.4-home" > "${HOME}/.R-version"
  RENV_DIR="$HOME" run renv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${RENV_ROOT}/versions/1.2.3"
  run renv-local 1.2.3
  assert_success ""
  assert [ "$(cat .R-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .R-version
  mkdir -p "${RENV_ROOT}/versions/1.2.3"
  run renv-local
  assert_success "1.0-pre"
  run renv-local 1.2.3
  assert_success ""
  assert [ "$(cat .R-version)" = "1.2.3" ]
}

@test "unsets local version" {
  touch .R-version
  run renv-local --unset
  assert_success ""
  assert [ ! -e .R-version ]
}
