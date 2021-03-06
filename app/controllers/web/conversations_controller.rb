class Web::ConversationsController < WebController

  def show
    @topic = Handle.lookup(params[:id])

    if current_user.new_record?
      force_user_login!
    else
      @convo = Conversation.where(user_id: current_user.id, topic_id: @topic.id).first
      if @convo
        authorize(@convo,:show?)
        @payload = ConversationSerializer.new(@convo)
      end
    end
  end

  def info
    @topic = Handle.lookup(params[:id])

    if current_user.new_record?
      force_user_login!
    else
      @convo = Conversation.where(user_id: current_user.id, topic_id: @topic.id).first
      @convo ||= Conversation.request(user: current_user, topic: @topic)
      authorize(@convo, :show?)
      @payload = ConversationSerializer.new(@convo)
    end
  end

private

  def force_user_login!
    flash[:notice] = "You have to log in before accessing this conversation."
    session[:redirect_url] = cloud_url("foo")
    redirect_to login_path
  end

end
