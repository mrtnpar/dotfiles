const path = require('path')
const fs = require('fs')
const https = require('https')

const fileExist = require('../helpers/file-exist')

const home = process.env.HOME
const filePath = path.resolve(`${home}/.local/share/nvim/site/autoload/plug.vim`)

const url =
  'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
const file = fs.createWriteStream(filePath)

const fetchFile = new Promise((resolve, reject) => {
  https
    .get(url, res => {
      res.on('data', chunk => file.write(chunk))
      res.on('error', err => reject(err))
      res.on('end', () => resolve(true))
    })
})

const installVimPlugForNvim = {
  title: 'Installing VIM Plugin Manager',
  task: (ctx, task) => {
    if (fileExist(filePath)) {
      task.skip()
    } else {
      fetchFile
        .catch(() => task.skip())
    }
  }
}

module.exports = installVimPlugForNvim
