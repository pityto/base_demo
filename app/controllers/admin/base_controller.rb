class Admin::BaseController < ActionController::Base
  protect_from_forgery with: :exception
  layout "application"
  respond_to :html
  before_action :authenticate_employee!, :check_permissions

  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_employee)
  end

  def check_permissions
    auth_controller_name = ::Service::PermissionUtils.convert_controller_name(controller_path)
    if ::Service::PermissionUtils.need_check_permission(auth_controller_name)
      auth_action_name = ::Service::PermissionUtils.convert_action_name(action_name)
      authorize! auth_action_name.to_sym, auth_controller_name
    end
  end
end
