class Admin::BaseController < ActionController::Base
  protect_from_forgery with: :exception
  layout "application"
  respond_to :html
  before_action :authenticate_employee!

  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
  end
end
