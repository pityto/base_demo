class Employee < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable#, :trackable, :validatable

  has_and_belongs_to_many :roles, :join_table => :employees_roles

  enum position_level: {
    staff: 0,        # 员工
    charge: 1,       # 主管
    manager: 2,      # 经理
    chief_officer: 3 # 总监
  }

  enum job_status: {
    on_job: 1,             #在职
    leave_office: -1       #离职
  }

  # 管理员角色
  def admin?
    has_role? 'admin'
  end

  # 是否属于某个角色
  def has_role?(role_tag)
    Employee.emp_role_cache(self.id).include? role_tag.to_s
  end

  def self.emp_role_cache(id)
    return [] if id.to_i == 0
    Rails.cache.fetch("employee_#{id}_roles", expires_in: 30.minute) do
      e = Employee.find_by_id id
      e.present? ? e.roles.pluck(:name) : []
    end
  end

  def self.get_all_with_options
    Rails.cache.fetch("all_employees", expires_in: 30.minute) do
     Employee.all.order(:name).map {|emp| [emp.name,emp.id]}
    end
  end
end
