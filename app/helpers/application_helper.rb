module ApplicationHelper
	
  def display_entity_status(entity,attribute,with_style=false)
    return if entity.nil?
    s = display_model_status(entity.class,attribute,entity.send(attribute))
    s = "<span class=\"status_#{attribute}_#{entity.send(attribute)}\">#{s}</span>".html_safe if with_style
    s
  end
  
  def display_model_status(model,attribute,value)
    return if value.nil?
    if ::I18n.exists?("activerecord.status.#{model.name.underscore}.#{attribute}.#{value}")
      key = "activerecord.status.#{model.name.underscore}.#{attribute}.#{value}"
    else
      key = "activerecord.status.#{attribute}.#{value}"
    end
    I18n.t(key,:default => value)
  end

  def select_options_from_enum(model,attribute,opts=nil)
    options = model.send(attribute.to_s.pluralize) if options.blank? && model.respond_to?(attribute.to_s.pluralize)
    return [] if options.blank?
    mappings = options.keys
    mappings.keep_if{|k| opts[:values].map(&:to_s).include?(k.to_s)} if opts && opts[:values].present? && opts[:values].is_a?(Array)
    mappings.map{|key| [display_model_status(model,attribute,key),key]}
  end

  def select_options_from_i18n(model,attribute,options=nil)
    if ::I18n.exists?("activerecord.status.#{model.name.underscore}.#{attribute}")
      key = "activerecord.status.#{model.name.underscore}.#{attribute}"
    else
      key = "activerecord.status.#{attribute}"
    end
    return [] if !I18n.backend.exists?(I18n.config.locale, key)
    mappings = I18n.backend.translate(I18n.config.locale, key).dup # dup 以免后续处理影响到 cache里的数据
    mappings.keep_if{|k,v| options[:values].map(&:to_s).include?(k.to_s)} if options && options[:values].present? && options[:values].is_a?(Array)
    mappings.map{|k, v| [v, k.to_s] }
  end

  def link_to_with_permissions(name = nil, options = nil, html_options = nil, &block)
    html_options, options, name = options, name, block if block_given?
    options ||= {}
    entity = html_options.delete(:entity)
    entity.current_employee = current_employee if entity.respond_to?(:current_employee)
    entity.current_ability = current_ability if entity.respond_to?(:current_ability)

    active_class = html_options.delete(:active_class)
    html_options = convert_options_to_data_attributes(options, html_options)

    url = url_for(options)
    html_options['href'] ||= url
    method = html_options['data-method'].present?? html_options['data-method'] : 'get'
    r = Rails.application.routes.recognize_path(url, method: method, subdomain: 'www')
    if active_class.present? && controller_path  == r[:controller]
      html_options['class'] = "#{html_options['class']} #{active_class}".strip
    end
    auth_controller_name = ::Service::PermissionUtils.convert_controller_name(r[:controller])
    auth_action_name = ::Service::PermissionUtils.convert_action_name(r[:action])
    if ::Service::PermissionUtils.need_check_permission(auth_controller_name)
      if can?(auth_action_name.to_sym, auth_controller_name)
        if entity.blank? || can?(auth_action_name.to_sym, entity)
          content_tag(:a, name || url, html_options, &block)
        end
      end
    else
      content_tag(:a, name || url, html_options, &block)
    end
  end
end
