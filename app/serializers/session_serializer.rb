class SessionSerializer < ActiveModel::Serializer

  attributes :id, :socket, :faye

  embed :ids,   include: true

  delegate :conversations, to: :user

  has_one  :user, polymorphic: true, serializer: MeSerializer
  has_many :conversations, key: :conversations


  def id
    SecureRandom.hex()
  end

  def faye
    {
      id: SecureRandom.hex(8),
      http: Figaro.env.faye_http_url!,
      https: Figaro.env.faye_https_url!,
      timeout: 120
    }
  end

  def socket
    {
      channel: "/v2/#{object.user.id}/session"
    }
  end

private

  # Public: Method to deal with Sprockets errors.
  def config; Rails.application.config.action_controller; end

  # Public: Method to deal with Sprockets errors.
  def controller; nil; end

end
