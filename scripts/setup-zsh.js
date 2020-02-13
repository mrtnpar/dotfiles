const fs = require('fs')
const util = require('util')

const appendFile = util.promisify(fs.appendFile)
const home = process.env.HOME
const chunk = require('../zsh/config')
const filePath = `${home}/.zshrc`

const isChunkOnFile = (filePath, str = '@mparees/config') => {
  const readStream = fs.createReadStream(filePath)
  return new Promise((resolve, reject) => {
    readStream.on('data', chunk => {
      if (chunk.toString().includes(str)) {
        resolve(true)
      }
    })
    readStream.on('end', () => resolve(false))
  })
}

const setupZsh = {
  title: 'Appending config to .zshrc',
  task: (ctx, task) =>
    isChunkOnFile(filePath)
      .then((isChunkOnFile) => {
        if (isChunkOnFile) {
          task.skip()
        } else {
          appendFile(filePath, chunk)
        }
      })
}

module.exports = setupZsh
