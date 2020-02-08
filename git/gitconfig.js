const appConfig = require('rc')('dotfiles')

const gitConfig = appConfig => `
[color]
  ui = auto
[alias]
  st = status
  di = diff
  ci = commit
  br = branch
  llog = log --date=local
  m = merge --no-ff
  co = checkout
  d = difftool
[rerere]
  enabled = true
[core]
  excludesfile = ${appConfig.git.core.excludesfile}
  autocrlf = input
[user]
  name = ${appConfig.user.name}
  email = ${appConfig.user.email}
`

module.exports = gitConfig(appConfig)
