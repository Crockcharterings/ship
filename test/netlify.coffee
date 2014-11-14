path    = require 'path'
node    = require 'when/node'
request = require 'request'
config  = require '../config'

describe 'netlify', ->

  it 'deploys a site to netlify', ->
    project = new Ship(root: path.join(_path, 'deployers/netlify'), deployer: 'netlify')

    if process.env.TRAVIS
      project.configure
        name: 'ship-testing'
        access_token: config.netlify.access_token

    project.deploy()
      .tap (res) ->
        node.call(request, res.url)
        .tap (r) -> r[0].body.should.match /netlify deployer working, yay!/
      .then -> project.deploy()
      .tap (res) -> res.destroy()
      .catch (err) -> console.error(err); throw err
      .should.be.fulfilled
