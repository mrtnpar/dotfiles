const append = `
# start @mparees/config
if type nvim > /dev/null 2>&1; then
  alias vim='nvim'
  export EDITOR='nvim'
else
  export EDITOR='vim'
fi

if [[ "$unamestr" == 'Darwin' ]]; then
  export TERM='xterm-256color-italic'
fi

alias tmux='TERM=xterm-256color-italic tmux'
# end @mparees/config
`

module.exports = append
