bitballoon = require 'bitballoon'
W          = require 'when'
node       = require 'when/node'
_          = require 'lodash'

module.exports = (root, config) ->
  d = W.defer()

  if not config.access_token then return d.reject('missing access_token!')
  client = bitballoon.createClient(access_token: config.access_token)

  W().with(root: root, client: client, config: config, d: d)
    .then(lookup)
    .then (site) -> if site then site else create.call(@)
    .then(deploy)
    .done (site) ->
      d.resolve
        deployer: 'bitballoon'
        url: site.url
        destroy: destroy.bind(@, site.site_id)
    , d.reject

  return d.promise

###*
 * Checks to see if your site is already on bitballoon or not. Returns either a
 * site object or undefined.
 * @return {Promise} promise for either undefined or a site object
###

lookup = ->
  node.call(@client.sites.bind(@client))
    .then (sites) => _.find(sites, name: @config.name)

###*
 * Creates a new site on bitballoon with a given name.
 * @return {Promise} promise for a newly created site object
###

create = ->
  @d.notify("Creating '#{@config.name}' on bitballoon")
  node.call(@client.createSite.bind(@client), name: @config.name)

###*
 * Creates a new deploy for a given site with the contents of the root.
 * @param {Object} site - a bit object from bitballoon
 * @return {Promise} a promise for a finished deployment
###

deploy = (site) ->
  @d.notify("Deploying '#{@config.name}'")
  node.call(site.createDeploy.bind(site), dir: @root)
    .then (deploy) -> node.call(deploy.waitForReady.bind(deploy))

###*
 * Deletes a given site from bitballoon.
 * @param  {Object} site - a site object from bitballoon
 * @return {Promise} a promise for the deleted site
###

destroy = (id) ->
  node.call(@client.site.bind(@client), id)
  .then (site) -> node.call(site.destroy.bind(site))
