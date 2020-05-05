#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RENV_TEST_DIR"
  cd "$RENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  echo "system" > "$1"
}

@test "detects global 'version' file" {
  create_file "${RENV_ROOT}/version"
  run renv-version-file
  assert_success "${RENV_ROOT}/version"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${RENV_ROOT}/version" ]
  assert [ ! -e ".R-version" ]
  run renv-version-file
  assert_success "${RENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".R-version"
  run renv-version-file
  assert_success "${RENV_TEST_DIR}/.R-version"
}

@test "in parent directory" {
  create_file ".R-version"
  mkdir -p project
  cd project
  run renv-version-file
  assert_success "${RENV_TEST_DIR}/.R-version"
}

@test "topmost file has precedence" {
  create_file ".R-version"
  create_file "project/.R-version"
  cd project
  run renv-version-file
  assert_success "${RENV_TEST_DIR}/project/.R-version"
}

@test "RENV_DIR has precedence over PWD" {
  create_file "widget/.R-version"
  create_file "project/.R-version"
  cd project
  RENV_DIR="${RENV_TEST_DIR}/widget" run renv-version-file
  assert_success "${RENV_TEST_DIR}/widget/.R-version"
}

@test "PWD is searched if RENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.R-version"
  cd project
  RENV_DIR="${RENV_TEST_DIR}/widget/blank" run renv-version-file
  assert_success "${RENV_TEST_DIR}/project/.R-version"
}

@test "finds version file in target directory" {
  create_file "project/.R-version"
  run renv-version-file "${PWD}/project"
  assert_success "${RENV_TEST_DIR}/project/.R-version"
}

@test "fails when no version file in target directory" {
  run renv-version-file "$PWD"
  assert_failure ""
}
