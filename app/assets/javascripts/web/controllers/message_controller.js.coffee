Cloudsdale.MessageController = Ember.Controller.extend

  content: null

  text: ( () ->
    @content.get('content')
  ).property('content.content')

  avatar: ( () ->
    @content.get('author').get('avatar') if @content.get('author')
  ).property('content.author.avatar')

  name: ( () ->
    @content.get('author').get('displayName') if @content.get('author')
  ).property('content.author.displayName')

  handle: ( () ->
    @content.get('author').get('username') if @content.get('author')
  ).property('content.author.username')

  createdAt: ( () ->
    console.log @content.get('createdAt')
    @content.get('createdAt')
  ).property('content.createdAt')

  updatedAt: ( () ->
    @content.get('updatedAt')
  ).property('content.updatedAt')

  timestamp: ( () ->
    @content.get('timestamp')
  ).property('content.timestamp')