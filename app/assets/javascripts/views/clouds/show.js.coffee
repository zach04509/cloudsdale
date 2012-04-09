class Cloudsdale.Views.CloudsShow extends Backbone.View
 
  template: JST['clouds/show']
  
  model: 'cloud'
  tagName: 'div'
  className: 'view-container'
  
  initialize: ->
    @render()
    @bind()
  
  render: ->
    $(@el).html(@template(model: @model)).attr('data-cloud-id',@model.id)
    this
  
  bind: ->
    $(@el).bind 'clouds:show', (event,cloud_id) =>
      @show() if cloud_id == @model.id
  
  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')
    if @.$('.chat-container').length == 0
      @chat_view = new Cloudsdale.Views.CloudsChat(model: @model)
      @.$('.float-container').html(@chat_view.el)
    else
      @chat_view.correctContainerScroll(true)