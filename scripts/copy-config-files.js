const fs = require('fs')
const path = require('path')
const util = require('util')

const copyFile = util.promisify(fs.copyFile)

const home = process.env.HOME
const fileName = 'gitignore_global'
const sourcePath = path.resolve('./git', `${fileName}`)
const destinyPath = path.resolve(home, `.${fileName}`)

const copyConfigFiles = {
  title: 'Copying config files',
  task: (ctx, task) =>
    copyFile(sourcePath, destinyPath)
      .then(err => err && task.skip())

}

module.exports = copyConfigFiles
