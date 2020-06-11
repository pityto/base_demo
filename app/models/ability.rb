class Ability
  include CanCan::Ability

  def initialize(employee)
    # :manage -> represent any action
    # :all -> represent any object.
    cannot :manage, :all if employee.blank?
    if employee.is_a?(::Employee) && employee.present?
      can :manage, :all if employee&.admin?
      employee.roles.includes(:permissions).each do |role|
        role.permissions.each do |permission|
          can permission.action.to_sym, permission.controller
        end
      end
      can :update, 'admin/hr/employees'
    end
  end

end
