-- Shell completion script generators for soop.
-- This module deliberately emits scripts that query `soop __complete
-- templates` at completion time, so installed templates stay current.

local M = {}

function M.bash(command)
  command = command or "soop"
  return ([=[_%s_complete() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "$prev" in
      new|n|details|d)
        COMPREPLY=( $(compgen -W "$(%s __complete templates)" -- "$cur") )
        return
        ;;
    esac

    if [[ "$cur" == -* ]]; then
      COMPREPLY=( $(compgen -W "--dry-run --interactive -i --mise --no-color --templates-dir --help" -- "$cur") )
    else
      COMPREPLY=( $(compgen -W "new n list ls details d create completion" -- "$cur") )
    fi
  }

  complete -F _%s_complete %s
]=]):format(command, command, command, command)
end

function M.zsh(command)
  command = command or "soop"
  return ([=[#compdef %s

# Allow this generated script to be sourced directly from .zshrc. When it is
# installed as ~/.zfunc/_soop, compinit will already have loaded compdef.
if (( ! $+functions[compdef] )); then
  autoload -Uz compinit
  compinit
fi

_%s() {
  local -a commands templates options
  commands=(
    'new:Scaffold a project'
    'n:Scaffold a project'
    'list:List templates'
    'ls:List templates'
    'details:Show template details'
    'd:Show template details'
    'create:Create a template'
    'completion:Generate shell completion'
  )
  options=(--dry-run --interactive -i --mise --no-color --templates-dir --help)
  templates=(${(f)"$(%s __complete templates)"})

  _arguments \
    '1:command:->command' \
    '*:argument:->argument'

  case "$state" in
    command) _describe 'command' commands ;;
    argument)
      case "${words[2]}" in
        new|n|details|d) _describe 'template' templates ;;
        *) _describe 'option' options ;;
      esac
      ;;
  esac
}

compdef _%s %s
]=]):format(command, command, command, command, command)
end

function M.fish(command)
  command = command or "soop"
  return ([=[complete -c %s -f -n '__fish_use_subcommand' -a 'new n list ls details d create completion'
complete -c %s -f -n '__fish_seen_subcommand_from new n details d' -a '(%s __complete templates)'
complete -c %s -l dry-run -n '__fish_use_subcommand'
complete -c %s -l interactive -s i -n '__fish_use_subcommand'
complete -c %s -l mise -n '__fish_use_subcommand'
complete -c %s -l no-color -n '__fish_use_subcommand'
complete -c %s -l templates-dir -r -n '__fish_use_subcommand'
]=]):format(command, command, command, command, command, command, command, command)
end

return M
