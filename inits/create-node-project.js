const fs = require('fs')
const path = require('path')
const cmd = require('node-cmd')

const paths = [
  {
    name: 'LICENSE',
    path: path.join(__dirname, '../LICENSE'),
    command: 'npx license mit > LICENSE'
  },
  {
    name: '.gitignore',
    path: path.join(__dirname, '../.gitignore'),
    command: 'npx gitignore node'
  },
  {
    name: 'npm init',
    path: path.join(__dirname, '../package.json'),
    command: 'npm init -y'
  }
]

paths.forEach(({ name, path, command }) => {
  fs.access(path, fs.F_OK, (err) => {
    if (err) {
      console.log(`${name} does not exists. CREATING`)
      return cmd.run(command)
    }
    console.log(`${name} file exists. SKIPPING`)
  })
})
