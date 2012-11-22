class Cloudsdale.Models.Ban extends Backbone.Model

  url: -> "/v1/#{@get('jurisdiction_type')}s/#{@get('jurisdiction_id')}/bans"

  defaults:
    reason: ""
    due: new Date
    revoke: false
    is_active: true
    has_expired: false
    jurisdiction_id: undefined
    jurisdiction_type: undefined
    offender_id: undefined
    enforcer_id: undefined
    is_transient: true

  initialize: (args,options) ->
    args ||= {}

    if args.jurisdiction
      @set('jurisdiction_id',args.jurisdiction.id)
      @set('jurisdiction_type',args.jurisdiction.type)
      delete @attributes['jurisdiction']

    if args.enforcer
      @set('enforcer_id',args.enforcer.id)
      delete @attributes['enforcer']

    this

  jurisdiction: ->
    return session.get("#{@get('jurisdiction_type')}s").findOrInitialize { id: @get('jurisdiction_id') },
      fetch: false

  enforcer: (args) ->
    args ||= {}
    args.fetch = if args.fetch then args.fetch else false

    console.log @

    return session.get('users').findOrInitialize { id: @get('enforcer_id') },
      fetch: args.fetch

  offender: (args) ->
    args ||= {}
    args.fetch = if args.fetch then args.fetch else false

    return session.get('users').findOrInitialize { id: @get('offender_id') },
      fetch: args.fetch

  dueDate: -> @due().toString("MM/dd/yyyy")
  dueTime: -> @due().toString("HH:mm:ss")
  due: -> new Date(@get('due'))

  toJSON: ->
    obj =
      id: @id
      reason: @get('reason')
      sentence: @get('sentence')
      due: @due()
      offender_id: @get('offender_id')

    return obj
