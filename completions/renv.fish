function __fish_renv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'renv' ]
    return 0
  end
  return 1
end

function __fish_renv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c renv -n '__fish_renv_needs_command' -a '(renv commands)'
for cmd in (renv commands)
  complete -f -c renv -n "__fish_renv_using_command $cmd" -a \
    "(renv completions (commandline -opc)[2..-1])"
end
