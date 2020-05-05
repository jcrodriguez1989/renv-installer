#!/usr/bin/env bats

load test_helper

@test "prefixes" {
  mkdir -p "${RENV_TEST_DIR}/bin"
  touch "${RENV_TEST_DIR}/bin/R"
  chmod +x "${RENV_TEST_DIR}/bin/R"
  mkdir -p "${RENV_ROOT}/versions/2.7.10"
  RENV_VERSION="system:2.7.10" run renv-prefix
  assert_success "${RENV_TEST_DIR}:${RENV_ROOT}/versions/2.7.10"
  RENV_VERSION="2.7.10:system" run renv-prefix
  assert_success "${RENV_ROOT}/versions/2.7.10:${RENV_TEST_DIR}"
}

@test "should use dirname of file argument as RENV_DIR" {
  mkdir -p "${RENV_TEST_DIR}/dir1"
  touch "${RENV_TEST_DIR}/dir1/file.r"
  RENV_FILE_ARG="${RENV_TEST_DIR}/dir1/file.r" run renv echo RENV_DIR
  assert_output "${RENV_TEST_DIR}/dir1"
}

@test "should follow symlink of file argument (#379, #404)" {
  mkdir -p "${RENV_TEST_DIR}/dir1"
  mkdir -p "${RENV_TEST_DIR}/dir2"
  touch "${RENV_TEST_DIR}/dir1/file.r"
  ln -s "${RENV_TEST_DIR}/dir1/file.r" "${RENV_TEST_DIR}/dir2/symlink.r"
  RENV_FILE_ARG="${RENV_TEST_DIR}/dir2/symlink.r" run renv echo RENV_DIR
  assert_output "${RENV_TEST_DIR}/dir1"
}

@test "should handle relative symlinks for file argument (#580)" {
  mkdir -p "${RENV_TEST_DIR}"
  cd "${RENV_TEST_DIR}"
  touch file.r
  ln -s file.r symlink.r
  RENV_FILE_ARG="symlink.r" run renv echo RENV_DIR
  assert_output "${RENV_TEST_DIR}"
}
