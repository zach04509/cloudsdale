class Message
  
  include AMQPConnector
  
  include Mongoid::Document
  
  attr_accessor :client_id
  
  embedded_in :chat
  belongs_to :author, class_name: "User"
  
  field :timestamp,   type: Time,    default: -> { Time.now }
  field :content,     type: String
  
  # Meta attributes
  field :user_name,   type: String
  field :user_path,   type: String
  field :user_avatar, type: String
  field :urls,        type: Array,    default: []
  
  validates :timestamp,   :presence => true
  validates :content,     :presence => true
  validates :author,      :presence => true
  
  before_validation do
    set_foreign_attributes! if author
  end
  
  after_save do
    enqueue!("messages",self.to_queue)
  end
  
  def to_queue
    self.to_json(:only => [:author_id,:content,:user_name,:user_path,:user_avatar], methods: [:id,:utc_timestamp,:topic_id,:topic_type,:client_id])
  end
  
  def topic_type
    chat.topic._type.downcase
  end
  
  def topic_id
    chat.topic._id.to_s
  end
  
  def utc_timestamp
    self[:timestamp].utc
  end
  
  def content=(msg)
    msg.gsub! /<\/?[^>]*>/, ""
    msg.gsub! /[\u000d\u0009\u000c\u0085\u2028\u2029\n]/, "<br/>"
    msg.gsub! /<br\/><br\/>/,"<br/>"
    msg.gsub! /^\s*$/, ""
    
    if (m = msg.match(/^(.*)/i))
      msg = m[0].gsub /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_\:]*)(\/?[a-z0-9\!\'\"\.\,\-\_\/\?\:\&\=\#\%\+\(\)]*)/i do
        protocol = $1
        top_dom = $2
        path = $3
        pjax_enabled = !(top_dom =~ /cloudsdale.org/i).nil?
        url = protocol + top_dom + path
        self[:urls] ||= []
        self[:urls] << url
        "<a class='chat-link' href='#{url}' #{!pjax_enabled ? "target='_blank' data-skip-pjax='true'" : ''}>#{url}</a>"
      end
    end
    
    self[:content] = msg
  end
  
  private
  
  def set_foreign_attributes!
    self[:user_name] = self.author.name
    self[:user_path] = "/users/#{author._id.to_s}"
    self[:user_avatar] = author.avatar.thumb.url
  end
  
end