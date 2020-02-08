const execa = require('execa')
const Listr = require('listr')

const filePath = require('../helpers/file-path')
const fileExist = require('../helpers/file-exist')

new Listr([
  {
    title: 'Creating LICENSE.',
    task: (ctx, task) => {
      if (!fileExist(filePath('../LICENSE'))) {
        execa('npx license mit > LICENSE')
          .then(() => console.log('LICENSE Created.'))
          .catch(() => task.skip())
      } else {
        task.skip()
      }
    }
  }
]).run()
