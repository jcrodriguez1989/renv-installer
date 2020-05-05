#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${RENV_ROOT}/shims" ]
  assert [ ! -d "${RENV_ROOT}/versions" ]
  run renv-init -
  assert_success
  assert [ -d "${RENV_ROOT}/shims" ]
  assert [ -d "${RENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run renv-init -
  assert_success
  assert_line "command renv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run renv-init - bash
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/renv.bash'"
}

@test "detect parent shell" {
  SHELL=/bin/false run renv-init -
  assert_success
  assert_line "export RENV_SHELL=bash"
}

@test "detect parent shell from script" {
  mkdir -p "$RENV_TEST_DIR"
  cd "$RENV_TEST_DIR"
  cat > myscript.sh <<OUT
#!/bin/sh
eval "\$(renv-init -)"
echo \$RENV_SHELL
OUT
  chmod +x myscript.sh
  run ./myscript.sh /bin/zsh
  assert_success "sh"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run renv-init - fish
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/renv.fish'"
}

@test "fish instructions" {
  run renv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'status --is-interactive; and source (renv init -|psub)'
}

@test "option to skip rehash" {
  run renv-init - --no-rehash
  assert_success
  refute_line "renv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run renv-init - bash
  assert_success
  assert_line 0 'export PATH="'${RENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run renv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${RENV_ROOT}/shims' \$PATH"
}

@test "can add shims to PATH more than once" {
  export PATH="${RENV_ROOT}/shims:$PATH"
  run renv-init - bash
  assert_success
  assert_line 0 'export PATH="'${RENV_ROOT}'/shims:${PATH}"'
}

@test "can add shims to PATH more than once (fish)" {
  export PATH="${RENV_ROOT}/shims:$PATH"
  run renv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${RENV_ROOT}/shims' \$PATH"
}

@test "outputs sh-compatible syntax" {
  run renv-init - bash
  assert_success
  assert_line '  case "$command" in'

  run renv-init - zsh
  assert_success
  assert_line '  case "$command" in'
}

@test "outputs fish-specific syntax (fish)" {
  run renv-init - fish
  assert_success
  assert_line '  switch "$command"'
  refute_line '  case "$command" in'
}
