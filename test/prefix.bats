#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${RENV_TEST_DIR}/myproject"
  cd "${RENV_TEST_DIR}/myproject"
  echo "1.2.3" > .R-version
  mkdir -p "${RENV_ROOT}/versions/1.2.3"
  run renv-prefix
  assert_success "${RENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  RENV_VERSION="1.2.3" run renv-prefix
  assert_failure "renv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${RENV_TEST_DIR}/bin"
  touch "${RENV_TEST_DIR}/bin/R"
  chmod +x "${RENV_TEST_DIR}/bin/R"
  RENV_VERSION="system" run renv-prefix
  assert_success "$RENV_TEST_DIR"
}

@test "prefix for system in /" {
  mkdir -p "${BATS_TEST_DIRNAME}/libexec"
  cat >"${BATS_TEST_DIRNAME}/libexec/renv-which" <<OUT
#!/bin/sh
echo /bin/R
OUT
  chmod +x "${BATS_TEST_DIRNAME}/libexec/renv-which"
  RENV_VERSION="system" run renv-prefix
  assert_success "/"
  rm -f "${BATS_TEST_DIRNAME}/libexec/renv-which"
}

@test "prefix for system in /" {
  mkdir -p "${BATS_TEST_DIRNAME}/libexec"
  cat >"${BATS_TEST_DIRNAME}/libexec/renv-which" <<OUT
#!/bin/sh
echo /bin/R
OUT
  chmod +x "${BATS_TEST_DIRNAME}/libexec/renv-which"
  RENV_VERSION="system" run renv-prefix
  assert_success "/"
  rm -f "${BATS_TEST_DIRNAME}/libexec/renv-which"
}

@test "prefix for invalid system" {
  PATH="$(path_without R)" run renv-prefix system
  assert_failure "renv: system version not found in PATH"
}
