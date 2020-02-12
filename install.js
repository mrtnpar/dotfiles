#!/usr/bin/env node

const fs = require('fs')
const util = require('util')
const Listr = require('listr')
const execa = require('execa')
const commandExists = require('command-exists')

const lastInstructions = require('./zsh/config')

const mkdir = util.promisify(fs.mkdir)
const appendFile = util.promisify(fs.appendFile)

const home = process.env.HOME
const requirements = ['zsh', 'git', 'vim', 'tmux']
const prepareDirectories = ['.vim/files/swap/', '.config/nvim']

const requirementsTasks = requirements.map(req => ({
  title: `Checking dependency ${req}`,
  task: (ctx, task) =>
    commandExists(req)
      .catch(() => task.skip())
}))

const prepareDirectoriesTasks = prepareDirectories.map(dir => {
  const fullPath = `${home}/${dir}`
  return {
    title: `Creating directories ${dir}`,
    task: (ctx, task) =>
      mkdir(fullPath, { recursive: true })
        .catch(() => task.skip())
  }
})

const printInstructions = {
  title: 'Appending config to .zshrc',
  task: (ctx, task) =>
    appendFile(`${home}/.zshrc`, lastInstructions)
      .then(foo => console.log(foo))
      .catch(() => task.skip())
}

new Listr([
  ...requirementsTasks,
  ...prepareDirectoriesTasks
  // ...copyConfigFiles,
  // ...installZsh,
  // ...installVimPlug,
  // ...installVimPlugForNvim,
  // ...installTmuxPlugins,
  // ...installingXtermProfile,
  // printInstructions
]).run()
