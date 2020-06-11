class Admin::Hr::RolesController < Admin::BaseController
  before_action :set_role, only: [:edit, :update, :permission]

  def index
    @q = SearchParams.new(params[:search_params] || {})
    search_params = @q.attributes(self)
    @roles = Role.default_where(search_params)
  end

  def show
    @role = Role.find(params[:id])
  end

  def new
    @role = Role.new
  end

  def create
    if Role.where(name: role_params[:name].to_s.strip).exists?
      flash[:msg] = '添加失败，角色名（英文）重复'
      redirect_back fallback_location: {action: :new}
      return
    end
    Role.create(name: role_params[:name].to_s.strip, name_cn: role_params[:name_cn].to_s.strip)
    flash[:notice] = '添加成功'
    redirect_back fallback_location: {action: :new}
  end

  def edit
  end

  def update
    if Role.where(name: role_params[:name].to_s.strip).where.not(id: @role.id).exists?
      flash[:msg] = '修改失败，角色名（英文）重复'
      redirect_back fallback_location: { action: :edit, id: @rold.id }
      return
    end
    @role.update(name: role_params[:name].strip, name_cn: role_params[:name_cn].strip)
    redirect_to admin_hr_roles_url
  end

  def permission
    @permissions = Permission.all
    @menus = []
    @permissions.group_by{ |p| p.controller[0, p.controller.rindex("/")] }.each { |k, v| @menus << k }
    @group_permissions = Permission.all.group(:controller)
    @selected_permission_ids = @role.permissions.pluck(:id).join(',')
    @role_permission = RolePermission.new
  end

  def update_permission
    role_id = params[:id].to_i
    old_permission_ids = RolePermission.where(role_id: role_id).pluck(:permission_id)
    new_permission_ids = params[:permission_id].present? ? params[:permission_id].map { |new_permission_id| new_permission_id.to_i } : []
    #添加以前没有的权限
    add_permission_ids = new_permission_ids - old_permission_ids
    add_permission_ids.each do |add_permission_id|
      RolePermission.create(role_id: role_id, permission_id: add_permission_id)
    end
    #删除现在没有的权限
    delete_permission_ids = old_permission_ids - new_permission_ids
    RolePermission.where(role_id: role_id, permission_id: delete_permission_ids).destroy_all if delete_permission_ids.present?
    redirect_to admin_hr_roles_url
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name, :name_cn)
  end

end
