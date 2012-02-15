class Users::DropsController < ApplicationController
  
  before_filter do
    @user = User.find(params[:user_id])
  end

  def create
    @drop = @user.create_drop_deposit_from_url_by_user(params[:url],current_user)
    respond_to do |format|
      format.html { redirect_to :back }
      if @drop.valid?
        format.js { render partial: 'drops/drop', locals: { drop: @drop, deposits: @drop.deposits.where(:depositable_id => @user.id), depositable: @user } }
      else
        format.js { render text: '' } # THIS SHOULD RETURN AN ALERT DIV TO THE CLIENT
      end
    end
  end
  
end