const path = require('path')

const fileOnRoot = fileName => path.join(__dirname, `../${fileName}`)

module.exports = fileOnRoot
