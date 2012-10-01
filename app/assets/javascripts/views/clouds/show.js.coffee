class Cloudsdale.Views.CloudsShow extends Backbone.View
 
  template: JST['clouds/show']
  
  model: 'cloud'
  tagName: 'div'
  className: 'view-container cloud-container'
  
  events:
    'click a.btn[data-action="settings"]' : 'toggleSettings'
    'click a.btn[data-action="rules"]'    : 'toggleRules'
    'click a.btn[data-action="drops"]'    : 'toggleDrops'
    'click a.btn[data-action="leave"]'    : 'leaveCloud'
    'click a.btn[data-action="destroy"]'  : 'destroyCloud'
      
  initialize: ->
    
    @render()
    @bindEvents()
    
    @refreshGfx()
  
  render: ->
    $(@el).html(@template(model: @model)).attr('data-page-id',@model.id)
    this
  
  bindEvents: ->
    $(@el).bind 'page:show', (event,page_id) =>
      if page_id == @model.id
        @show() 
      else
        @purgeOldDialog()
    
    @model.on 'change', (model) =>
      @refreshGfx()
    
    session.get('user').on 'change', (model) =>
      @refreshGfx()
      
    $(@el).bind "clouds:leave", (event,cloud) =>
      if cloud.id == @model.id
        @unbindEvents()
        $(@el).remove()
    
    nfc.on "#{@model.type}s:#{@model.id}", (payload) =>
      @model.set(payload)
      
    $(@el).bind "#{@model.type}s:#{@model.id}:users:show", (event,_id) =>
      user = session.get('users').findOrInitialize { id: _id }
      @toggleUser(user)
    
    $(@el).bind "#{@model.type}s:#{@model.id}:users:prosecution", (event,_model) =>
      @toggleProsecution(_model)
      
    $(@el).bind "#{@model.type}s:#{@model.id}:users:prosecute", (event,_id) =>
      offender = session.get('users').findOrInitialize { id: _id }
            
      _model = if _model then _model else new Cloudsdale.Models.Prosecution({
        crime_scene_id: @model.id,
        crime_scene_type: @model.type,
        offender_id: offender.id,
        prosecutor_id: session.get('user').id
      })
            
      @toggleProsecution(_model)
    
  unbindEvents: ->
    $(@el).unbind('page:show').unbind("clouds:leave")
  
  refreshGfx: () ->
    @.$('.cloud-head .cloud-head-avatar').css('background-image',"url(#{@model.get('avatar').normal})")
    @.$('.cloud-head > .cloud-head-inner > h2').text(@model.get('name'))
    @.$('.cloud-head > .cloud-head-inner > p').text(@model.get('description'))
    
    resizeBottomWrapper(@.$('.cloud-sidebar-bottom'))
  
  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')
    
    if @.$('.chat-wrapper').children().length > 0
      @chat_view.correctContainerScroll(true)
    else
      @chat_view = new Cloudsdale.Views.CloudsChat(model: @model)
      @.$('.float-container > .container-inner > .chat-wrapper').replaceWith(@chat_view.el)
      
    
    if @.$('.cloud-sidebar-bottom').children().length == 0
      @users_view = new Cloudsdale.Views.CloudsUsers(model: @model)
      @.$('.cloud-sidebar-bottom').append(@users_view.el)
    
    @refreshGfx()
  
  toggleSettings: (event) ->
    view = new Cloudsdale.Views.CloudsSettingsDialog(cloud: @model)
    @renderDialog(view)
    
  toggleRules: (event) ->
    view = new Cloudsdale.Views.CloudsRulesDialog(model: @model)
    @renderDialog(view)
  
  toggleDrops: (event) ->
    view = new Cloudsdale.Views.CloudsDropsDialog(model: @model)
    @renderDialog(view)
  
  toggleUser: (_model) ->
    view = new Cloudsdale.Views.CloudsUserDialog(model: _model, topic: @model)
    @renderDialog(view)
  
  toggleProsecution: (_model) ->    
    view = new Cloudsdale.Views.CloudsProsecutionDialog(model: _model)
    @renderDialog(view)
  
  purgeOldDialog: (args) ->
    
    args = {} unless args
    
    if @.$('.fixed-container > .container-inner.container-inner-secondary').length > 0
      @.$('.fixed-container > .container-inner.container-inner-secondary').parent().removeClass('show-secondary')
      setTimeout =>
        @.$('.fixed-container > .container-inner.container-inner-secondary').remove()
        args.callback() if args.callback
      , 400
    else
      args.callback() if args.callback
  
  renderDialog: (view) ->
    @purgeOldDialog
      callback: =>
        @.$('.fixed-container').append(view.el)
        @.$('.fixed-container').addClass('show-secondary')
        resizeBottomWrapper()
        
    false
    
  leaveCloud: (event) ->
    session.get('user').leaveCloud @model
    $.event.trigger "clouds:leave", @model
    Backbone.history.navigate("/",true)
    false
  
  destroyCloud: (event) ->
    answer = confirm "Are you sure you want to destroy #{@model.get('name')}"
    if answer == true
      $.event.trigger "clouds:leave", @model
      Backbone.history.navigate("/",true)
      @model.destroy()
    false
    
      
    