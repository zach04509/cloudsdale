class Drop

  include AMQPConnector

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::FullTextSearch

  ## Preview Uploader specific
  mount_uploader :preview, PreviewUploader
  field :preview_dimensions,    type: Hash,       default: { width: 0, height: 0 }
  field :preview_file_type,     type: String,     default: ""

  embeds_many :deposits

  field :url,                 type: String
  field :match_id,            type: String
  field :status,              type: Array
  field :strategy,            type: Symbol

  field :title,               type: String

  field :src_meta,            type: Hash,         default: {}
  field :last_load,           type: DateTime
  field :hidden,              type: String,       default: "false"

  belongs_to :local_reference, polymorphic: true

  validates :url, presence: true, format: /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_\:]*)(\/?[a-z0-9\'\"\.\,\-\_\/\?\:\&\=\#\%\+\(\)]*)/i
  validates :match_id, presence: true
  validates :title, presence: true

  scope :expired, -> { where( :last_load.gt => 1.week.ago ) }
  scope :only_visable, where(hidden: false)
  scope :after_on_topic, -> time, topic { where(:"deposits.#{topic.id}_updated_at".lt => time, "deposits.depositable_id" => topic.id) }
  scope :order_by_topic, -> topic { order_by(["deposits.#{topic.id.to_s}_updated_at",:desc]) }
  scope :with_preview_image, where(:preview.ne => nil)

  fulltext_search_in :search_string, :filters => {
    :depositable_ids => lambda { |drop| drop.deposits.map { |deposit| deposit.depositable_id.to_s } }
  }

  before_save do
    re_fetch if last_load.nil? or last_load < 1.week.ago
    self[:src_meta] = {}.deep_merge(self[:src_meta].to_hash)
    self[:_type] = "Drop"
  end

  def self.find_or_initialize_from_matched_url(url)
    begin
      response  = Urifetch.fetch(url)

      match_id  = response.data['match_id'] || url

      drop = Drop.find_or_initialize_by(match_id: match_id)

      if response.status.include?("200")
        drop.set_data(response)
      else
        drop.status = response.status
      end
    rescue OpenURI::HTTPError
      return nil
    rescue ArgumentError
      return nil
    rescue IOError
      return nil
    end

    drop
  end

  # Public: Translates the Drop object to a Hash string using RABL
  #
  #   args - A Hash of arguments to be sent to the rabl, renderer.
  #
  # Examples
  #
  # @user.to_hash
  # # => { name: "..." }
  #
  # Returns a Hash.
  def to_hash(args={})
    defaults = { template: "api/v1/drops/base", view_path: 'app/views' }
    options = defaults.merge(args)

    Rabl.render(self, options[:template], :view_path => options[:view_path], :format => 'hash')
  end

  # Internal: The string which will be used to index a drop.
  #
  # Returns the of the Drop.
  def search_string
    [self.title].join(' ')
  end

  def visitable?
    status[0].to_s == "200"
  end

  def re_fetch
    set_data Urifetch.fetch(url)
    has_been_loaded = true
  end

  def re_fetch!
    re_fetch
    save
  end

  def set_data(response)
    self[:strategy]   = response.strategy_key
    self[:status]     = response.status
    self[:src_meta]   = response.data

    self[:title]      = response.data['title'] || self[:match_id]

    self[:url]        = self[:match_id]

    self[:last_load]  = -> { DateTime.current }.call
    if src_meta['image']
      set_preview_image(src_meta['image'],src_meta['image_local'])
    end
  end

  def hidden_as_string
    val = self[:hidden] || "false"
    { hidden: val.to_s }
  end

  def preview_versions
    { default: self.preview.url }
  end

  def set_preview_image(file,local=false)
    unless file.nil? and local.nil?
      if (local == false) or local.nil?
        # Triggers if file is Remote
        self.remote_preview_url = file
      elsif (local == true)
        # Triggers if file is a File or Tempfile
        self.preview = open(file)
      end
    end
  end

  # Override to silently ignore trying to remove missing
  # previous avatar when destroying a User.
  def remove_preview!
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
    end
  end

  # Override to silently ignore trying to remove missing
  # previous avatar when saving a new one.
  def remove_previously_stored_preview
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
      @previous_model_for_avatar = nil
    end
  end

end
