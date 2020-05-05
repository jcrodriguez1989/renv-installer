#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${RENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$RENV_TEST_DIR"
  cd "$RENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${RENV_ROOT}/versions" ]
  run renv-version
  assert_success "system (set by ${RENV_ROOT}/version)"
}

@test "set by RENV_VERSION" {
  create_version "3.3.3"
  RENV_VERSION=3.3.3 run renv-version
  assert_success "3.3.3 (set by RENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "3.3.3"
  cat > ".R-version" <<<"3.3.3"
  run renv-version
  assert_success "3.3.3 (set by ${PWD}/.R-version)"
}

@test "set by global file" {
  create_version "3.3.3"
  cat > "${RENV_ROOT}/version" <<<"3.3.3"
  run renv-version
  assert_success "3.3.3 (set by ${RENV_ROOT}/version)"
}

@test "set by RENV_VERSION, one missing" {
  create_version "3.3.3"
  RENV_VERSION=3.3.3:1.2 run renv-version
  assert_failure
  assert_output <<OUT
renv: version \`1.2' is not installed (set by RENV_VERSION environment variable)
3.3.3 (set by RENV_VERSION environment variable)
OUT
}

@test "set by RENV_VERSION, two missing" {
  create_version "3.3.3"
  RENV_VERSION=3.4.2:3.3.3:1.2 run renv-version
  assert_failure
  assert_output <<OUT
renv: version \`3.4.2' is not installed (set by RENV_VERSION environment variable)
renv: version \`1.2' is not installed (set by RENV_VERSION environment variable)
3.3.3 (set by RENV_VERSION environment variable)
OUT
}

renv-version-without-stderr() {
  renv-version 2>/dev/null
}

@test "set by RENV_VERSION, one missing (stderr filtered)" {
  create_version "3.3.3"
  RENV_VERSION=3.4.2:3.3.3 run renv-version-without-stderr
  assert_failure
  assert_output <<OUT
3.3.3 (set by RENV_VERSION environment variable)
OUT
}
