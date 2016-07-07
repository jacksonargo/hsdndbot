class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :permissions_denied

  before_action :require_login

  private

  def require_login
    redirect_to "/login" unless current_user
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def permission_denied
    render :file => "public/401.html", :status => :unauthorized, :layout => false
  end
end
