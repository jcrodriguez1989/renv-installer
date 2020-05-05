#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run renv-help
  assert_success
  assert_line "Usage: renv <command> [<args>]"
  assert_line "Some useful renv commands are:"
}

@test "invalid command" {
  run renv-help hello
  assert_failure "renv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${RENV_TEST_DIR}/bin"
  cat > "${RENV_TEST_DIR}/bin/renv-hello" <<SH
#!shebang
# Usage: renv hello <world>
# Summary: Says "hello" to you, from renv
# This command is useful for saying hello.
echo hello
SH

  run renv-help hello
  assert_success
  assert_output <<SH
Usage: renv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${RENV_TEST_DIR}/bin"
  cat > "${RENV_TEST_DIR}/bin/renv-hello" <<SH
#!shebang
# Usage: renv hello <world>
# Summary: Says "hello" to you, from renv
echo hello
SH

  run renv-help hello
  assert_success
  assert_output <<SH
Usage: renv hello <world>

Says "hello" to you, from renv
SH
}

@test "extracts only usage" {
  mkdir -p "${RENV_TEST_DIR}/bin"
  cat > "${RENV_TEST_DIR}/bin/renv-hello" <<SH
#!shebang
# Usage: renv hello <world>
# Summary: Says "hello" to you, from renv
# This extended help won't be shown.
echo hello
SH

  run renv-help --usage hello
  assert_success "Usage: renv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${RENV_TEST_DIR}/bin"
  cat > "${RENV_TEST_DIR}/bin/renv-hello" <<SH
#!shebang
# Usage: renv hello <world>
#        renv hi [everybody]
#        renv hola --translate
# Summary: Says "hello" to you, from renv
# Help text.
echo hello
SH

  run renv-help hello
  assert_success
  assert_output <<SH
Usage: renv hello <world>
       renv hi [everybody]
       renv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${RENV_TEST_DIR}/bin"
  cat > "${RENV_TEST_DIR}/bin/renv-hello" <<SH
#!shebang
# Usage: renv hello <world>
# Summary: Says "hello" to you, from renv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run renv-help hello
  assert_success
  assert_output <<SH
Usage: renv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
