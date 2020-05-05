#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${RENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$RENV_TEST_DIR"
  cd "$RENV_TEST_DIR"
}

stub_system_R() {
  local stub="${RENV_TEST_DIR}/bin/R"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_R
  assert [ ! -d "${RENV_ROOT}/versions" ]
  run renv-versions
  assert_success "* system (set by ${RENV_ROOT}/version)"
}

@test "not even system R available" {
  PATH="$(path_without R)" run renv-versions
  assert_failure
  assert_output "Warning: no R detected on the system"
}

@test "bare output no versions installed" {
  assert [ ! -d "${RENV_ROOT}/versions" ]
  run renv-versions --bare
  assert_success ""
}

@test "single version installed" {
  stub_system_R
  create_version "3.3"
  run renv-versions
  assert_success
  assert_output <<OUT
* system (set by ${RENV_ROOT}/version)
  3.3
OUT
}

@test "single version bare" {
  create_version "3.3"
  run renv-versions --bare
  assert_success "3.3"
}

@test "multiple versions" {
  stub_system_R
  create_version "2.7.6"
  create_version "3.3.3"
  create_version "3.4.0"
  run renv-versions
  assert_success
  assert_output <<OUT
* system (set by ${RENV_ROOT}/version)
  2.7.6
  3.3.3
  3.4.0
OUT
}

@test "indicates current version" {
  stub_system_R
  create_version "3.3.3"
  create_version "3.4.0"
  RENV_VERSION=3.3.3 run renv-versions
  assert_success
  assert_output <<OUT
  system
* 3.3.3 (set by RENV_VERSION environment variable)
  3.4.0
OUT
}

@test "bare doesn't indicate current version" {
  create_version "3.3.3"
  create_version "3.4.0"
  RENV_VERSION=3.3.3 run renv-versions --bare
  assert_success
  assert_output <<OUT
3.3.3
3.4.0
OUT
}

@test "globally selected version" {
  stub_system_R
  create_version "3.3.3"
  create_version "3.4.0"
  cat > "${RENV_ROOT}/version" <<<"3.3.3"
  run renv-versions
  assert_success
  assert_output <<OUT
  system
* 3.3.3 (set by ${RENV_ROOT}/version)
  3.4.0
OUT
}

@test "per-project version" {
  stub_system_R
  create_version "3.3.3"
  create_version "3.4.0"
  cat > ".R-version" <<<"3.3.3"
  run renv-versions
  assert_success
  assert_output <<OUT
  system
* 3.3.3 (set by ${RENV_TEST_DIR}/.R-version)
  3.4.0
OUT
}

@test "ignores non-directories under versions" {
  create_version "3.3"
  touch "${RENV_ROOT}/versions/hello"

  run renv-versions --bare
  assert_success "3.3"
}

@test "lists symlinks under versions" {
  create_version "2.7.8"
  ln -s "2.7.8" "${RENV_ROOT}/versions/2.7"

  run renv-versions --bare
  assert_success
  assert_output <<OUT
2.7
2.7.8
OUT
}

@test "doesn't list symlink aliases when --skip-aliases" {
  create_version "1.8.7"
  ln -s "1.8.7" "${RENV_ROOT}/versions/1.8"
  mkdir moo
  ln -s "${PWD}/moo" "${RENV_ROOT}/versions/1.9"

  run renv-versions --bare --skip-aliases
  assert_success

  assert_output <<OUT
1.8.7
1.9
OUT
}
