#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RENV_TEST_DIR"
  cd "$RENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${RENV_ROOT}/version" ]
  run renv-version-origin
  assert_success "${RENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$RENV_ROOT"
  touch "${RENV_ROOT}/version"
  run renv-version-origin
  assert_success "${RENV_ROOT}/version"
}

@test "detects RENV_VERSION" {
  RENV_VERSION=1 run renv-version-origin
  assert_success "RENV_VERSION environment variable"
}

@test "detects local file" {
  echo "system" > .R-version
  run renv-version-origin
  assert_success "${PWD}/.R-version"
}

@test "reports from hook" {
  create_hook version-origin test.bash <<<"RENV_VERSION_ORIGIN=plugin"

  RENV_VERSION=1 run renv-version-origin
  assert_success "plugin"
}

@test "carries original IFS within hooks" {
  create_hook version-origin hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export RENV_VERSION=system
  IFS=$' \t\n' run renv-version-origin env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "doesn't inherit RENV_VERSION_ORIGIN from environment" {
  RENV_VERSION_ORIGIN=ignored run renv-version-origin
  assert_success "${RENV_ROOT}/version"
}
