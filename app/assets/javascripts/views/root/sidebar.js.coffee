class Cloudsdale.Views.RootSidebar extends Backbone.View

  template: JST['root/sidebar']

  model: 'session'

  tagName: 'div'
  className: 'sidebar'

  events:
    'click #status-online'  : -> @toggleStatus('online')
    'click #status-offline' : -> @toggleStatus('offline')
    'click #status-away'    : -> @toggleStatus('away')
    'click #status-busy'    : -> @toggleStatus('busy')
    'click #cloud-new > a'      : 'toggleNewCloud'
    'click #donation-new > a'   : 'toggleNewDonation'
    'submit #new_cloud'     : 'saveCloud'

  initialize: (args) ->
    @render()
    @bindEvents()
    @refreshGfx()
    @initializeConversations()
    this

  render: ->
    $(@el).html(@template(model: @model))
    this

  refreshGfx: ->
    @.$('#status-current').removeClass("status-busy").removeClass("status-away")
    .removeClass("status-online").removeClass("status-offline")
    .addClass("status-#{session.get('user').get('preferred_status')}")

  bindEvents: ->
    $(@el).mousewheel (event, delta) ->
      @scrollTop -= (delta * 30)
      event.preventDefault()
    @.$('.sidebar-list#sidebar-clouds').sortable
      axis: 'y'
      stop: (event, ui) =>
        @refreshListPositions()

    session.get('user').on 'change', (e) =>
      @refreshGfx()

    @.$('#status-current').bind 'click', (e) =>
      @.$('#status-current').toggleClass('active')

    $(@el).bind 'clouds:join', (event,conversation) => @renderConversation(conversation)

    $(document).bind 'keydown', (e) =>

      activeToggle = @.$('.sidebar-item.active')

      if ((e.keyCode == 38) or (e.keyCode == 40)) and e.shiftKey

        if e.keyCode == 40
          next = activeToggle.next()
          if next.length > 0
            id = next.attr('data-entity-id')
            Backbone.history.navigate("/clouds/#{id}",true)

        if e.keyCode == 38
          prev = activeToggle.prev()
          if prev.length > 0
            id = prev.attr('data-entity-id')
            Backbone.history.navigate("/clouds/#{id}",true)

  toggleStatus: (status) ->
    session.get('user').set('preferred_status',status)
    session.get('user').save()
    @.$('#status-current').removeClass('active')

  initializeConversations: ->
    session.get('clouds').each (cloud) =>
      @renderConversation(cloud)

    @reorderClouds()
    @refreshListPositions()

  renderConversation: (conversation) ->

    if @.$("#sidebar-clouds.sidebar-list > li[data-entity-id=#{conversation.id}]").length == 0
      view = new Cloudsdale.Views.CloudsToggle(model: conversation)
      @.$('#sidebar-clouds.sidebar-list').append(view.el)

  refreshListPositions: ->
    @.$("ul#sidebar-clouds > li").each (index,elem) =>
      _pos = @.$(elem).prevAll().length
      localStorage["cloud:#{@.$(elem).attr('data-entity-id')}:toggle:pos"] = _pos

  reorderClouds: ->
    _elements = @.$("ul#sidebar-clouds > li")
    _elements.sort (a,b) ->
      posA = localStorage["cloud:#{$(a).attr('data-entity-id')}:toggle:pos"]
      posB = localStorage["cloud:#{$(b).attr('data-entity-id')}:toggle:pos"]
      compA = if typeof posA == 'string' then parseInt(posA) else 1000
      compB = if typeof posB == 'string' then parseInt(posB) else 1000
      return (if (compA < compB) then -1 else (if (compA > compB) then 1 else 0))

    @.$("ul#sidebar-clouds").append(_elements)

  moveToggleFirst: (cloud) ->
    toggle = @.$("ul#sidebar-clouds > li.sidebar-item[data-entity-id=#{cloud.id}]")
    @.$('.sidebar > ul#sidebar-clouds').prepend(toggle)

  toggleNewCloud: ->
    @.$('#cloud-new').toggleClass('active')
    @.$('#new_cloud_name').focus()
    false

  toggleNewDonation: ->
    @.$('#donation-new').toggleClass('active')
    $.ajax
      type: 'GET'
      url: '/v1/donations.json'
      dataType: "json"
      success: (resp) =>

        statistics = resp.result.donation_statistics

        @.$('.donation-statistics-amount').text("$ #{statistics.amount}")
        @.$('.donation-statistics-goal').text("#{statistics.goal}")

        @.$('.donation-statistics-supporters').text(statistics.supporters)
        supporters_label = "supporter"
        supporters_label << "s" if statistics.supporters > 1
        @.$('.donation-statistics-supporters-label').text(supporters_label)
        deadline = new Date(statistics.deadline).toRelativeTime()
        @.$('.donation-statistics-deadline').text(deadline)

        @.$('.donation-progress > .bar').css('width',"#{statistics.complete}%")
        if statistics.complete >= 19
          @.$('.donation-progress > .bar').text("#{statistics.complete}%")

        @.$('#new_donation > a.submit').attr('href',resp.result.donation_url)
      error: (resp) =>
        console.log resp

    false

  buildErrors: (errors) ->
    t = "<ul style='text-align: left;'>"
    $.each errors, (index,error) ->
      t += "<li><strong>#{error.ref_node}</strong> #{error.message}</li>" if error.type == "field"
      t += "<li><strong>#{error.message}</strong></li>" if error.type == "general"
    t += "</ul>"

  saveCloud: ->

    newCloud = new Cloudsdale.Models.Cloud()

    newCloud.set 'name', @.$('#new_cloud_name').val()
    newCloud.save {},
      success: (cloud) =>
        console.log cloud
        session.get('clouds').add(cloud)
        Backbone.history.navigate("/clouds/#{cloud.id}",true)
        if (((10).days().ago() > session.get('user').memberSince()) and session.get('clouds').where({"owner_id":session.get('user').id}).length < 1) or _.include(["founder","developer"],session.get('user').get('role'))
          @.$('#new_cloud_name').val("")
          @toggleNewCloud()
        else
          @.$('#cloud-new').remove()

      error: (model,resp) =>
        response = $.parseJSON(resp.responseText)
        @.$('#new_cloud_errors').html("<div class='sidebar-form-errors'>
          #{@buildErrors(response.errors)}
        </div>")

    false

