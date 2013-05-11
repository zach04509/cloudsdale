class ApplicationController < ActionController::Base

  include Pundit

  helper_method :current_user

  before_filter :auth_token
  before_filter :redirect_on_maintenance!, :set_time_zone_for_user!, :assert_user_ban!

  # Rescues the error yielded from not finding requested document
  rescue_from Mongoid::Errors::DocumentNotFound do |message|
    render status: 404
  end

  # Rescues the error from not being authorized to perform an action
  rescue_from Pundit::NotAuthorizedError do |message|
    render status: 403
  end

  # Rescues the errors yielded by supplying a faulty BSON id
  rescue_from Moped::Errors::InvalidObjectId do |message|
    render status: 500
  end

  rescue_from ActionController::ParameterMissing do |message|
    flash[:error] = "Invalid parameters, please try again."
    redirect_to root_path, status: 422
  end

  def current_user

    if session[:user_id]
      @current_user ||= User.find_or_initialize_by(_id: session[:user_id])
    elsif auth_token
      @current_user ||= User.find_or_initialize_by(auth_token: auth_token)
    else
      @current_user ||= User.new
    end

  end

  # Public: Takes rails errors and ....
  def errors_to_string(errors)
    str = ""
    errors.each { |k,v| str += "#{k.to_s.gsub(/[\.\_\-]/i,' ')}: #{v}" }
    flash[:error] = str
  end

protected

  # Internal: Forces users that are not of role moderator or higher to get redirected to
  # the maintenence page. The site will still work as normal even though maintenance
  # mode is activated for the users with sufficient rights.
  #
  # Returns nothing of intrest.
  def redirect_on_maintenance!
    if MAINTENANCE
      unless current_user and current_user.role >= 2
        redirect_to maintenance_path
      end
    end
  end

  def set_time_zone_for_user!
    Time.zone = current_user.time_zone if current_user and current_user.time_zone
  end

  def assert_user_ban!
    if current_user.banned?
      redirect_to logout_path
    end
  end

  def auth_token
    @auth_token ||= cookies[:auth_token] || request.headers['X-Auth-Token']
  end

  def permitted_params
    PermittedParams.new(params,current_user)
  end

  def redirect_url
    @redirect_url ||= session[:redirect_url] || params[:redirect_url] || root_path
  end

  def redirect_to_stored_url
    url = redirect_url
    session[:redirect_url] = nil
    redirect_to url
  end

private

  # Private: Used to set a session for the user if the persist_session parameter is available.
  # It will also save the user to the database to ensure any new SHIT added to the user model
  # is persisted.
  def authenticate!(user)
    session[:user_id]    = user.id.to_s
    cookies[:auth_token] = auth_token
    @auth_token          = auth_token
    @current_user        = user
    user.save
  end

end
