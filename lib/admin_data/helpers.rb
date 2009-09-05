module AdminData::Helpers

  def admin_data_association_info_size(klass)
    return true if
     (admin_data_belongs_to_what(klass.name).size > 0)  || 
          (admin_data_has_many_what(klass.name).size > 0) ||
          (admin_data_has_one_what(klass.name).size > 0) 
  end

  def admin_data_stylesheet_link_tag(*args)
    tmp = []
    tmp << '<style>'
    args.each do |arg|
      f = File.new(File.join(AdminDataConfig.setting[:plugin_dir],'lib','css',"#{arg}.css"))
      tmp << f.read
    end
    tmp << '</style>'
    tmp.join
  end

  def admin_data_javascript_include_tag(*args)
    tmp = []
    tmp << '<script>'
    args.each do |arg|
      f = File.new(File.join(AdminDataConfig.setting[:plugin_dir],'lib','js',"#{arg}.js"))
      tmp << f.read
    end
    tmp << '</script>'
    tmp.join
  end

  def build_drop_down_for_klasses
    @klasses.inject([]) do |result,klass|
      result << [klass.name,  admin_data_list_url(:klass => klass.name)]
    end
  end

  def build_sort_options(klass)
    output = []
    klass.columns.each do |column|
      name = column.name

      selected_text = params[:sortby] == "#{name} desc" ? "selected='selected'" : ''
      output << "<option value='#{name} desc' #{selected_text}>&nbsp;#{name} desc</option>"

      selected_text = params[:sortby] == "#{name} asc" ? "selected='selected'" : ''
      output << "<option value='#{name} asc' #{selected_text}>&nbsp;#{name} asc</option>"
    end
    output.join
  end

  def admin_data_string_representation_of_data(value)
    case value
    when BigDecimal
      value.to_s
    when Date, DateTime, Time
      "'#{value.to_s(:db)}'"
    else
      value.inspect
    end
  end


  # Usage:
  #
  # admin_data_am_i_active(['main','index'])
  # admin_data_am_i_active(['main','index list'])
  # admin_data_am_i_active(['main','index list'],['search','advance_search'])
  def admin_data_am_i_active(*args)
    flag = false
    args.each do |arg|
      controller_name = arg[0]
      action_name = arg[1]
      action_names = action_name.split
      is_action_included = action_names.include?(params[:action])
      flag = params[:controller] == "admin_data/#{controller_name}" && is_action_included
      if flag
        return 'active' 
        break
      end
    end
    ''
  end

  # options supports :limit which is applied if the column type is string
  # or text
  #
  def admin_data_get_value_for_column(column, source, options = {})
    options.reverse_merge!(:limit => 400)
    if column.type == :datetime
      d = source.send(column.name)
      d.strftime('%m/%d/%Y %H:%M:%S %p') unless d.blank?
    else
      value = source.send(column.name)
      return value if options[:limit].blank?
      if column.type == :string || column.type == :text
        # truncate method fails in handling serialized array stored in string column
        begin
          truncate(value,:length => options[:limit])
        rescue
          '<actual data is not being shown because truncate method failed.>'
        end
      end
    end
  end

  def admin_data_belongs_to_what(klass_name)
    @klass = Object.const_get(klass_name)
    output = []
    @klass.reflections.each do |key,value|
      output << value.name.to_s if value.macro.to_s == 'belongs_to'
    end
    output
  end

  def admin_data_has_one_what(klass_name)
    @klass = Object.const_get(klass_name)
    output = []
    @klass.reflections.each do |key,value|
      output << value.name.to_s if value.macro.to_s == 'has_one'
    end
    output
  end

  def admin_data_has_many_what(klass_name)
    @klass = Object.const_get(klass_name)
    output = []
    @klass.reflections.each do |key,value|
      output << value.name.to_s if value.macro.to_s == 'has_many'
    end
    output
  end

  def admin_data_has_many_count(model,send)
    model.send(send.intern).count
  end

  def admin_data_get_belongs_to_class(model,belongs_to_string)
    begin
      tmp = model.send(belongs_to_string.intern)
      tmp.class.to_s if tmp
    rescue
      nil
    end
  end

  def admin_data_get_has_many_class(model,belongs_to_string)
    begin
      tmp = model.send(belongs_to_string.intern)
      tmp.find(:first).class if tmp.count > 0
    rescue
      nil
    end
  end

end
