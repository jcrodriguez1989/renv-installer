#!/usr/bin/env bats

load test_helper

@test "shell integration disabled" {
  run renv shell
  assert_failure "renv: shell integration not enabled. Run \`renv init' for instructions."
}

@test "shell integration enabled" {
  eval "$(renv init -)"
  run renv shell
  assert_success "renv: no shell-specific version configured"
}

@test "no shell version" {
  mkdir -p "${RENV_TEST_DIR}/myproject"
  cd "${RENV_TEST_DIR}/myproject"
  echo "1.2.3" > .R-version
  RENV_VERSION="" run renv-sh-shell
  assert_failure "renv: no shell-specific version configured"
}

@test "shell version" {
  RENV_SHELL=bash RENV_VERSION="1.2.3" run renv-sh-shell
  assert_success 'echo "$RENV_VERSION"'
}

@test "shell version (fish)" {
  RENV_SHELL=fish RENV_VERSION="1.2.3" run renv-sh-shell
  assert_success 'echo "$RENV_VERSION"'
}

@test "shell revert" {
  RENV_SHELL=bash run renv-sh-shell -
  assert_success
  assert_line 0 'if [ -n "${RENV_VERSION_OLD+x}" ]; then'
}

@test "shell revert (fish)" {
  RENV_SHELL=fish run renv-sh-shell -
  assert_success
  assert_line 0 'if set -q RENV_VERSION_OLD'
}

@test "shell unset" {
  RENV_SHELL=bash run renv-sh-shell --unset
  assert_success
  assert_output <<OUT
RENV_VERSION_OLD="\$RENV_VERSION"
unset RENV_VERSION
OUT
}

@test "shell unset (fish)" {
  RENV_SHELL=fish run renv-sh-shell --unset
  assert_success
  assert_output <<OUT
set -gu RENV_VERSION_OLD "\$RENV_VERSION"
set -e RENV_VERSION
OUT
}

@test "shell change invalid version" {
  run renv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
renv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${RENV_ROOT}/versions/1.2.3"
  RENV_SHELL=bash run renv-sh-shell 1.2.3
  assert_success
  assert_output <<OUT
RENV_VERSION_OLD="\$RENV_VERSION"
export RENV_VERSION="1.2.3"
OUT
}

@test "shell change version (fish)" {
  mkdir -p "${RENV_ROOT}/versions/1.2.3"
  RENV_SHELL=fish run renv-sh-shell 1.2.3
  assert_success
  assert_output <<OUT
set -gu RENV_VERSION_OLD "\$RENV_VERSION"
set -gx RENV_VERSION "1.2.3"
OUT
}
