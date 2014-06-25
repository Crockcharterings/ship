path    = require 'path'
request = require 'request'
nodefn  = require 'when/node'

describe 's3', ->

  it 'deploys a basic site to s3', ->
    progress_spy = sinon.spy()
    project = new Ship(root: path.join(_path, 'deployers/s3'), deployer: 's3')

    if process.env.TRAVIS
      project.configure
        access_key: process.env.S3_ACCESS_KEY
        secret_key: process.env.S3_SECRET_KEY
        bucket: 'ship-s3-test'
        ignore: ['ignoreme.html']

    project.deploy()
      .progress(progress_spy)
      .tap (res) ->
        nodefn.call(request, res.url)
        .tap (r) -> r[0].body.should.match /look ma, it worked/
      .tap (res) ->
        nodefn.call(request, "#{res.url}/ignoreme.html")
        .tap (r) -> r[0].body.should.not.match /i am a-scared/
      .then (res) -> res.destroy()
      .tap -> progress_spy.should.have.callCount(7)
      .should.be.fulfilled
