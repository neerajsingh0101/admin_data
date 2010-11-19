class AdminData::Util

  def self.google_hosted_jquery_ui_css(context)
    if AdminData::Config.setting[:use_google_hosting_for_jquery]
      jquery_ui_css = 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.7.2/themes/base/jquery-ui.css'
      jquery_ui_theme_css = 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.7.2/themes/blitzer/jquery-ui.css'
      context.send(:stylesheet_link_tag, jquery_ui_css, jquery_ui_theme_css)
    else
      stylesheet_link_tag('vendor/jquery-ui-1.7.2.custom')
    end
  end

  def self.google_hosted_jquery(context)
    if AdminData::Config.setting[:use_google_hosting_for_jquery]
      jquery_min = 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js'
      jquery_ui_min = 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.7.2/jquery-ui.min.js'
      context.send(:javascript_include_tag, jquery_min, jquery_ui_min)
    elsif Rails.env.test?
      #  It is breaking the html markup and test is full of messages like
      #  ignoring attempt to close string with script Hence not including jquery.form in test
    else
      javascript_include_tag('vendor/jquery-1.4.2', 'vendor/jquery-ui-1.7.2.custom.min')
    end
  end

  def self.is_allowed_to_view_feed?(controller)
    return true if Rails.env.development?

    if AdminData::Config.setting[:feed_authentication_user_id].blank?
      Rails.logger.info 'No user id has been supplied for feed'
      return false
    end

    if AdminData::Config.setting[:feed_authentication_password].blank?
      Rails.logger.info 'No password has been supplied for feed'
      return false
    end

    stored_userid = AdminData::Config.setting[:feed_authentication_user_id]
    stored_password = AdminData::Config.setting[:feed_authentication_password]
    self.perform_basic_authentication(stored_userid, stored_password, controller)
  end

  def self.perform_basic_authentication(stored_userid, stored_password, controller)
    controller.authenticate_or_request_with_http_basic do |input_userid, input_password|
      (input_userid == stored_userid) && (input_password == stored_password)
    end
  end


  def self.label_values_pair_for(model, view)
    data = model.class.columns.inject([]) do |sum, column|
      tmp = view.admin_data_get_value_for_column(column, model, :limit => nil)
      sum << [ column.name, (tmp.html_safe? ? tmp : view.send(:h,tmp)) ]
    end
    extension = AdminData::Extension.show_info(model)
    data + extension
  end

  def self.custom_value_for_column(column, model)
    # some would say that if I use try method then I will not be raising exception and
    # I agree. However in this case for clarity I would prefer to not to have try after each call
    begin
      AdminData::Config.setting[:column_settings].fetch(model.class.name.to_s).fetch(column.name.intern).call(model)
    rescue
      model.send(column.name)
    end
  end

  def self.get_serialized_value(html, column_value)
    html << %{ <i>Cannot edit serialized field.</i> }
    unless column_value.blank?
      html << %{ <i>Raw contents:</i><br/> }
      html << column_value.inspect
    end
    html.join
  end

  def self.pluralize(count, text)
    count > 1 ? text+'s' : text
  end

  # Rails method merge_conditions ANDs all the conditions. I need to ORs all the conditions
  def self.or_merge_conditions(klass, *conditions)
    s = ') OR ('
    cond = conditions.inject([]) do |sum, condition|
      condition.blank? ? sum : sum << klass.send(:sanitize_sql, condition)
    end.compact.join(s)
    "(#{cond})" unless cond.blank?
  end

  def self.camelize_constantize(klassu)
    klasss = klassu.camelize
    self.constantize_klass(klasss)
  end

  # klass_name = model_name.sub(/\.rb$/,'').camelize
  # constantize_klass(klass_name)
  def self.constantize_klass(klass_name)
    klass_name.split('::').inject(Object) do |klass, part|
      klass.const_get(part)
    end
  end

  def self.columns_order(klasss)
    klass = self.constantize_klass(klasss)
    columns = klass.columns.map(&:name)
    columns_symbol = columns.map(&:intern)

    columns_order = AdminData::Config.setting[:columns_order]

    if columns_order && columns_order[klasss]
      primary_key = klass.send(:primary_key).intern
      order = [primary_key] + columns_order.fetch(klasss)
      order.uniq!
      sanitized_order = order - (order - columns_symbol)
      sorted_columns = sanitized_order + (columns_symbol - sanitized_order)
      return sorted_columns.map(&:to_s)
    end

    # created_at and updated_at should be at the very end
    if columns_symbol.include? :created_at
      columns_symbol = (columns_symbol - [:created_at]) + [:created_at]
    end

    if columns_symbol.include? :updated_at
      columns_symbol = (columns_symbol - [:updated_at]) + [:updated_at]
    end

    columns_symbol.map(&:to_s)
  end

  # Usage: write 'hello world' to tmp/hello.txt file
  # Util.write_to_file('hello world', 'a+', 'tmp', 'hello.txt')
  def self.write_to_file(data, mode, *path)
    path = File.expand_path(Rails.root.join(*path.flatten.compact))
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, mode) {|fh| fh.puts(data) }
  end

  def self.javascript_include_tag(*args)
    data = args.inject([]) do |sum, arg|
      arg = "#{arg}.js" if arg !~ /js$/
      sum << ['<script type="text/javascript" src="/admin_data/public/js/', arg, '"></script>'].join
    end
    data.join("\n")
  end

  def self.stylesheet_link_tag(*args)
    data = args.inject([]) do |sum, arg|
      arg = "#{arg}.css" if arg !~ /css$/
      sum << ['<link href="/admin_data/public/css/', arg, '" media="screen" rel="stylesheet" type="text/css" />'].join
    end
    data.join("\n")
  end
  
  def self.string_representation_of_data(value)
    case value
    when BigDecimal
      value.to_s
    when Date, DateTime, Time
      "'#{value.to_s(:db)}'"
    else
      value.inspect
    end
  end

  def self.build_sort_options(klass, sortby)
    klass.columns.inject('') do |result, column|
      name = column.name

      selected_text = (sortby == "#{name} desc") ? "selected='selected'" : ''
      result << "<option value='#{name} desc' #{selected_text}>#{name} desc</option>"

      selected_text = (sortby == "#{name} asc") ? "selected='selected'" : ''
      result << "<option value='#{name} asc' #{selected_text}>#{name} asc</option>"
    end.html_safe
  end

  def self.associations_for(klass, association_type)
    klass.name.camelize.constantize.reflections.values.select do |value|
      value.macro == association_type
    end
  end

  def self.exception_info(e)
    "#{e.class}: #{e.message}#$/#{e.backtrace.join($/)}"
  end

end
