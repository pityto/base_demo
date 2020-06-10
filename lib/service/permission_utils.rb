module Service
  module PermissionUtils
    extend self
    ACTION_MAPS = {
      'new' => 'create',
      'edit' => 'update',
      'show' => 'read',
      'index' => 'read'
    }

    def convert_action_name(action_name)
      action_name = action_name.to_s.strip
      action_name = ACTION_MAPS[action_name] || action_name
      # action_name.sub(/^(new|create|update|edit|download|destroy|save)_/, '')
      action_name.sub(/^new_/, 'create_').sub(/^edit_/, 'update_')
    end

    def convert_controller_name(controller_name)
      controller_name.to_s
    end

    def need_check_permission(controller_name)
      controller_name = controller_name.to_s.strip
      return false if controller_name !~ /^admin/
      ignore_controllers = ['admin/dashboard', 'admin/notifications', 'admin/autocomplete', 'admin/trackings', 'admin/user_trackings']
      !ignore_controllers.include? controller_name
    end
  end
end

