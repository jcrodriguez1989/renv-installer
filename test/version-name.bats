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
  run renv-version-name
  assert_success "system"
}

@test "system version is not checked for existence" {
  RENV_VERSION=system run renv-version-name
  assert_success "system"
}

@test "RENV_VERSION can be overridden by hook" {
  create_version "2.7.11"
  create_version "3.5.1"
  create_hook version-name test.bash <<<"RENV_VERSION=3.5.1"

  RENV_VERSION=2.7.11 run renv-version-name
  assert_success "3.5.1"
}

@test "carries original IFS within hooks" {
  create_hook version-name hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export RENV_VERSION=system
  IFS=$' \t\n' run renv-version-name env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "RENV_VERSION has precedence over local" {
  create_version "2.7.11"
  create_version "3.5.1"

  cat > ".R-version" <<<"2.7.11"
  run renv-version-name
  assert_success "2.7.11"

  RENV_VERSION=3.5.1 run renv-version-name
  assert_success "3.5.1"
}

@test "local file has precedence over global" {
  create_version "2.7.11"
  create_version "3.5.1"

  cat > "${RENV_ROOT}/version" <<<"2.7.11"
  run renv-version-name
  assert_success "2.7.11"

  cat > ".R-version" <<<"3.5.1"
  run renv-version-name
  assert_success "3.5.1"
}

@test "missing version" {
  RENV_VERSION=1.2 run renv-version-name
  assert_failure "renv: version \`1.2' is not installed (set by RENV_VERSION environment variable)"
}

@test "one missing version (second missing)" {
  create_version "3.5.1"
  RENV_VERSION="3.5.1:1.2" run renv-version-name
  assert_failure
  assert_output <<OUT
renv: version \`1.2' is not installed (set by RENV_VERSION environment variable)
3.5.1
OUT
}

@test "one missing version (first missing)" {
  create_version "3.5.1"
  RENV_VERSION="1.2:3.5.1" run renv-version-name
  assert_failure
  assert_output <<OUT
renv: version \`1.2' is not installed (set by RENV_VERSION environment variable)
3.5.1
OUT
}

renv-version-name-without-stderr() {
  renv-version-name 2>/dev/null
}

@test "one missing version (without stderr)" {
  create_version "3.5.1"
  RENV_VERSION="1.2:3.5.1" run renv-version-name-without-stderr
  assert_failure
  assert_output <<OUT
3.5.1
OUT
}

@test "version with prefix in name" {
  create_version "2.7.11"
  cat > ".R-version" <<<"R-2.7.11"
  run renv-version-name
  assert_success
  assert_output "2.7.11"
}
