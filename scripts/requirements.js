const commandExists = require('command-exists')

const requirements = ['zsh', 'git', 'vim', 'tmux']

const requirementsTasks = requirements.map(req => ({
  title: `Checking dependency ${req}`,
  task: (ctx, task) =>
    commandExists(req)
      .catch(() => task.skip())
}))

module.exports = requirementsTasks
