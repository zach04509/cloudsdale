class Cloud
  
  include AMQPConnector
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::FullTextSearch
  
  include Droppable
  
  embeds_one :chat, as: :topic
  
  attr_accessor :user_invite_tokens
  
  attr_accessible :name, :description, :hidden, :locked, :remove_avatar, :avatar, :remote_avatar_url, :rules
  attr_accessible :owner_id, as: [:owner]
  
  field :name,          type: String
  field :description,   type: String
  field :rules,         type: String
  field :hidden,        type: Boolean,        default: false
  field :locked,        type: Boolean,        default: false
  field :featured,      type: Boolean,        default: false
  field :member_count,  type: Integer,        default: 0
   
  mount_uploader :avatar, AvatarUploader
  
  validates :name, presence: true, uniqueness: true, length: { within: 3..24 }
  validates :description, presence: true, length: { within: 5..50 }
  
  belongs_to :owner, polymorphic: true
  
  has_and_belongs_to_many :users,       :inverse_of => :clouds,             dependent: :nullify
  has_and_belongs_to_many :moderators,  :inverse_of => :clouds_moderated,   dependent: :nullify,  class_name: "User"
  
  scope :popular, order_by(:member_count, :desc)
  scope :recent, order_by(:created_at, :desc)
  
  fulltext_search_in :search_string, :filters => {
    :public => lambda { |cloud| cloud.hidden == false },
    :hidden => lambda { |cloud| cloud.hidden == true }
  }
  
  before_validation do
    
    # Sets a new Owner from among the moderators if owner id is nil.
    sedlf.owner = moderators.first if owner_id.nil? && !moderators.empty?
    
    # Sets a new Owner from among the users if owner id is nil.
    self.owner = users.first if owner_id.nil? && !users.empty?
    
    # Sets the owner to the user with the highest rank if owner_id is not present.
    self.owner = User.order_by(:role,:desc).first if owner.nil?
    
    # Adds owner_id to moderator_ids if moderator_ids does not include the owner id.
    self.moderators << owner unless moderator_ids.include?(owner_id)
    
     # Adds owner_id to user_ids if user_ids does not include the owner id.
    self.users << owner unless user_ids.include?(owner_id)
    
    # Adds a moderator id to user_ids if user_ids does not include the moderator id.
    self.moderator_ids.each do |mod_id|
      self.users << mod_id unless user_ids.include?(mod_id)
    end
            
    self[:name] = self[:name].slice(0..23) if name
    self[:user_ids].uniq!
    self[:moderator_ids].uniq!
  end
  
  before_save do
    
    self[:member_count] = self.user_ids.count
    self[:_type] = "Cloud"
    
    build_chat unless chat.present?
    
  end
  
  after_save do
    
    enqueue! "faye", { channel: "/clouds/#{self._id.to_s}", data: self.to_hash }
    
  end
  
  # Public: Translates the Cloud object to a HASH string using RABL
  #
  #   args - A Hash of arguments to be sent to the rabl, renderer.
  #
  # Examples
  # 
  # @cloud.to_hash
  # # => { name: "..." }
  #
  # Returns a Hash.
  def to_hash(args={})
    defaults = { template: "api/v1/clouds/base", view_path: 'app/views' }
    options = defaults.merge(args)
    
    Rabl.render(self, options[:template], :view_path => options[:view_path], :format => 'hash')
  end
  
  # Public: Determines which role a user has on an instance of a Cloud.
  #
  #   user - An instance of User.
  #
  # Returns a Symbol.
  def get_role_for(user)
    if user.id == self.owner_id
      return :owner
    elsif self.user_ids.include?(user.id)
      return :member
    else
      return :observer
    end
  end
  
  # Internal: The string which will be used to index a cloud.
  #
  # Returns the name and the description of the Cloud.
  def search_string
    [name, description].join(' ')
  end

  # Public: Fetches the URL's for the avatar versions
  #
  # args - A hash of arguments of what to do with the avatar versions.
  #
  #   :except - Array of the version keys to be omitted from the hash
  # 
  #   :only   - An array of specific keys you want to include.
  #             will be overridden by any values from except.
  #
  # Examples
  #
  # @user.avatar_versions([:normal,:mini,:thumb,:preview])
  # # => { chat: "http://..." }
  #
  # Returns a hash of keys pointing at url values.
  def avatar_versions(args={})
    
    args = { except: [], only: nil }.merge(args)
    
    allowed_keys = [:normal,:thumb,:mini,:preview,:chat]
    
    allowed_keys.select! { |value| args[:only].include? value } if args[:only]
    allowed_keys -= args[:except]
    
    {
      normal: avatar.url,
      mini: avatar.mini.url,
      thumb: avatar.thumb.url,
      preview: avatar.preview.url,
      chat: avatar.chat.url
      
    }.delete_if do |key,value|
      
      !allowed_keys.include? key
      
    end
      
  end

  # Override to silently ignore trying to remove missing
  # previous avatar when destroying a User.
  def remove_avatar!
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
    end
  end

  # Override to silently ignore trying to remove missing
  # previous avatar when saving a new one.
  def remove_previously_stored_avatar
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
      @previous_model_for_avatar = nil
    end
  end
  
end