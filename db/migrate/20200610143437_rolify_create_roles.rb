class RolifyCreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table(:roles) do |t|
      t.string :name, comment: "角色名称"
      t.string :name_cn, comment: "中文名"
      t.references :resource, :polymorphic => true
      t.timestamps
    end

    create_table(:employees_roles, :id => false) do |t|
      t.references :employee
      t.references :role
    end
    
    add_index(:roles, :name)
    add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:employees_roles, [ :employee_id, :role_id ])
  end
end
