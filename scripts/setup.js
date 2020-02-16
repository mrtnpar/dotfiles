const fs = require('fs')
const util = require('util')

const prepareDirectories = [
  '.vim/files/swap/',
  '.vim/autoload/',
  '.config/nvim',
  '.local/share/nvim/site/autoload'
]
const mkdir = util.promisify(fs.mkdir)
const home = process.env.HOME

const setupTasks = prepareDirectories.map(dir => {
  const fullPath = `${home}/${dir}`
  return {
    title: `Creating directories ${dir}`,
    task: (ctx, task) =>
      mkdir(fullPath, { recursive: true })
        .catch(() => task.skip())
  }
})

module.exports = setupTasks
