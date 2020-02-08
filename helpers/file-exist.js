const fs = require('fs')

const fileExist = filePath => {
  let result = false
  try {
    fs.accessSync(filePath, fs.constants.F_OK)
    result = true
  } catch (err) {
    result = false
  }
  return result
}

module.exports = fileExist
