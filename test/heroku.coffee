path    = require 'path'
request = require 'request'
nodefn  = require 'when/node'
config = require '../config'

describe 'heroku', ->

  it 'deploys a basic site to heroku', ->
    project = new Ship(root: path.join(_path, 'deployers/heroku'), deployer: 'heroku')
    progress_spy = sinon.spy()

    if process.env.TRAVIS
      project.configure
        name: 'ship-testing-app'
        api_key: config.heroku.api_key

    project.deploy()
      .progress(progress_spy)
      .tap -> progress_spy.should.have.been.calledWith('working')
      .tap (res) ->
        nodefn.call(request, res.url)
        .tap (r) -> r[0].body.should.match /look ma, it worked/
      .then (res) -> res.destroy()
      .should.be.fulfilled
