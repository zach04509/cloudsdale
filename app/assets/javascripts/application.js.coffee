#= require jquery
#= require jquery_ujs
#= require pjax
#= require jquery.cookie
#= require jquery.BetterGrow
#= require jquery.titlealert
#= require jquery.tokeninput
#= require bootstrap
#= require date
#= require rails.validations
#= require rails.validations.custom
#= require rails.validations.formbuilder
#= require farbtastic
#= require faye
#= require bottombar
#= require showdown

#= require main
#= require articles
#= require users
#= require sessions


$ ->

  hide_alert_message = (p) ->
    $(p).replaceWith("<div class='alert-message hidden'></div>")
    
  request = (options) ->
    $.ajax $.extend(
      url: options.url
      type: "get"
    , options)
    false
  
  load_javascript = (controller,action) ->
    $.event.trigger "application.load"
    $.event.trigger "#{controller}.load"
    $.event.trigger "#{action}.#{controller}.load"
  
  $('.topbar').dropdown()
    
  $(document).bind 'application.load', =>
    $(".alert-message > .close").bind "click", (e) ->
      hide_alert_message $(@).parent()

    $(".alert-message.primary").hide().fadeIn(500).delay(8000).fadeOut 500, ->
      hide_alert_message @

    $('[rel=twipsy]').twipsy()
    
  $(document).bind 'end.pjax', (a,b,c) ->
    controller = b.getResponseHeader('controller')
    action     = b.getResponseHeader('action')
    if controller != null and action != null
      load_javascript(b.getResponseHeader('controller'),b.getResponseHeader('action'))
      $("body").attr('class', "#{b.getResponseHeader('controller')} #{b.getResponseHeader('action')}")
  
  $(document).ready ->
    load_javascript($("body").data('controller'),$("body").data('action'))
    
  #$(window).scroll (e) ->
  #  h = $('html')
  #  max_height = h[0].scrollHeight
  #  current_height = $('body')[0].scrollTop
  #  h.css("background-position","center #{((current_height*-1)-70)}px")
  

  
  
  
  
  
  