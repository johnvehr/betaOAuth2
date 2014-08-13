class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  protect_from_forgery

  def new_session_path(scope)
    new_user_session_path
  end
end
