validateSchema = require('json-schema').validate
_ = require 'lodash'

class DeployerConfig
  ###*
   * JSON-Schema representation of the config. Just the properties object -
     the type & wrapper isn't needed because we assume the config is an
     object.
   * @type {Object}
  ###
  schema: {}

  ###*
   * The configuration data itself.
   * @type {Object}
  ###
  data: {}

  ###*
   * Validate DeployerConfig.data and throw an exception of it's invalid
   * @return {Object} The config data with defaults added
  ###
  validate: ->
    check = @_validateSchema()
    if check.errors.length isnt 0
      throw new Error(_.pluck(check.errors, 'message').join('\n'))
    return check.data

  ###*
   * A helper method that does the validation for a couple methods.
   * @return {Object} The "errors" key is an array of error objects, and the
     "valid" key is a Boolean if it is valid.
   * @private
  ###
  _validateSchema: ->
    # need a copy, see: https://github.com/kriszyp/json-schema/issues/37
    data = _.clone @data
    check = validateSchema(
      data
      {
        type: 'object'
        properties: @schema
      }
    )
    check.data = data
    return check

  ###*
   * Make sure that the value is valid for a given config option.
   * @param {String} option The option from the deployer config to validate.
   * @param {String} value The value to check
   * @return {Object} The "errors" key is an array of error objects, and the
     "valid" key is a Boolean if it is valid.
  ###
  validateOption: (option, value) ->
    check = validateSchema(
      value
      @schema[option]
    )

    # fixup the return object
    return {
      errors: _.pluck check.errors, 'message'
      valid: check.errors.length is 0
    }

  ###*
   * Get all the config values that need to be filled in.
   * @return {Array<String>}
  ###
  getMissingValues: ->
    check = @_validateSchema()
    if check.valid then return []
    return _.pluck(check.errors, 'property')

module.exports = DeployerConfig
