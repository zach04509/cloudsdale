object @message

node(:id) { |message| message._id.to_s }

attributes :timestamp, :content, :client_id

child(:author) do
  extends 'api/v1/users/mini', :view_path => 'app/views'
end