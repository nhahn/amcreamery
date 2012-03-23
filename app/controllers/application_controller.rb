class ApplicationController < ActionController::Base
  include ControllerAuthentication
  
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "You are not authorized to be here"
    redirect_to home_path
  end
end
