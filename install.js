#!/usr/bin/env node

const Listr = require('listr')
// const execa = require('execa')

const requirementsTasks = require('./scripts/requirements')
const setupTasks = require('./scripts/setup')
const copyConfigFiles = require('./scripts/copy-config-files')
const installZsh = require('./scripts/install-zsh')
const installVimPlug = require('./scripts/install-vim-plugin')
const installVimPlugForNvim = require('./scripts/install-vim-plugin-nvim')
const installTmuxPlugins = require('./scripts/install-tmux-plugins')
const installingXtermProfile = require('./scripts/install-xterm-profile')
const setupZsh = require('./scripts/setup-zsh')

new Listr([
  ...requirementsTasks,
  ...setupTasks,
  copyConfigFiles,
  installZsh,
  installVimPlug,
  installVimPlugForNvim,
  installTmuxPlugins,
  installingXtermProfile,
  setupZsh
]).run()
