class Cloudsdale.Models.Cloud extends Backbone.GSModel
  
  url: ->
    if @id
      "/v1/clouds/#{@id}.json"
    else
      "v1/clouds.json"
      
  type: 'cloud'
  
  setters:
    
    owner: (value) -> new Cloudsdale.Models.User(value)
      
    users: (value) ->
      new Cloudsdale.Collections.Users value,
        url: -> "/v1/clouds/#{@id}/users.json"
            
    moderators: (value) ->
      new Cloudsdale.Collections.Users value,
        url: -> "/v1/clouds/#{@id}/moderators.json"
    
  defaults:
    name: ""
    description: ""
    avatar: {}
    owner: -> new Cloudsdale.Models.User()
    moderators: -> new Cloudsdale.Collections.Users()
    users: -> new Cloudsdale.Collections.Users()
    is_transient: true
  
  initialize: (args) ->
    args = {} unless args
      
  removeAvatar: (options) ->
    attr = {}
    attr.remove_avatar = true
    return @save(attr,options)
  
  addUser: (user,options) ->
    # options = {} unless options
    # 
    # # collection = new Cloudsdale.Collections.Users attr.users,
    # #   url: "/v1/clouds/#{@id}/users.json"
    #     
    # collection.save()
  
  lastMessageAt: ->
    if @get('chat')
      new Date(@get('chat').last_message_at)
    else
      new Date(0)
  
  # Announces your chat presence in the chat room periodicly
  # every 27 seconds with a 3 second delay before restarting the timer
  #
  # Returns false.
  announcePresence: ->
    setTimeout( =>
      nfc.cli.publish "/clouds/#{@id}/users", session.get('user').toBroadcastJSON()
      setTimeout( =>
        @announcePresence()
      , 27000)
    , 3000)
    false