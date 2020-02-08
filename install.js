#!/usr/bin/env node

const path = require('path')
const cmd = require('node-cmd')
const Listr = require('listr')

const fileOnRoot = fileName => path.join(__dirname, `./${fileName}`)

console.log(fileOnRoot('package-lock.json'))

new Listr([
  {
    title: 'Removing package-lock',
    task: () => cmd.run('rm', [fileOnRoot('package-lock.json')])
  }
]).run()
