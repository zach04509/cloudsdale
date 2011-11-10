class MainController < ApplicationController
  
  before_filter only: [:index] do
    unless current_user
      redirect_to login_path
    end
  end
  
  def index
    @feartued_entry = Entry.where(promoted: true).first
    @recent_entries = Entry.where(published: true, hidden: false, promoted: false).order_by(:published_at,:desc).limit(3)
    @popular_entries = Entry.where(published: true, hidden: false, promoted: false, :published_at.gt => 3.days.ago).order_by([:views,:desc],[:comments,:desc],[:published_at,:desc]).limit(3)
  end

end
