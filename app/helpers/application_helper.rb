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

end
