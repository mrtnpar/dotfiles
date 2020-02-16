const path = require('path')
const fs = require('fs')
const https = require('https')
const execa = require('execa')

const fileExist = require('../helpers/file-exist')

const home = process.env.HOME
const shFilePath = path.resolve('/tmp/oh-my-zsh-install.sh')
const ohMyZshPath = path.resolve(`${home}/.oh-my-zsh`)

const url =
  'https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh'
const file = fs.createWriteStream(shFilePath)

const fetchFile = new Promise((resolve, reject) => {
  https
    .get(url, res => {
      res.on('data', chunk => file.write(chunk))
      res.on('error', err => reject(err))
      res.on('end', () => resolve(true))
    })
})

const installZsh = {
  title: 'Installing OH MY ZSH',
  task: (ctx, task) => {
    if (fileExist(ohMyZshPath)) {
      task.skip()
    } else {
      fetchFile
        .then(() =>
          execa.command(`sh ${shFilePath}`)
            .catch(() => task.skip())
        )
        .catch(() => task.skip())
    }
  }
}

module.exports = installZsh
