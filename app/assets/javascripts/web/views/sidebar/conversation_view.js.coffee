Cloudsdale.Sidebar ||= Ember.Namespace.create()
Cloudsdale.Sidebar.ConversationView = Ember.View.extend(
  templateName: 'sidebar/conversation'
  classNames: ['sidebar-conversation']
  tagName: 'li'

  classNameBindings: ['conversationTypeClass']

  conversationTypeClass: (->
    "conversation-topic-#{@model.get('topic').get('type')}"
  ).property("conversationTypeClass")

)
