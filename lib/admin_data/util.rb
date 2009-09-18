class AdminData::Util

  def self.javascript_include_tag(*args)
    tmp = []
    tmp << '<script>'
    args.each do |arg|
      f = File.new(File.join(AdminDataConfig.setting[:plugin_dir],'lib','js',"#{arg}.js"))
      tmp << f.read
    end
    tmp << '</script>'
    tmp.join
  end

  def self.stylesheet_link_tag(*args)
    tmp = []
    tmp << '<style>'
    args.each do |arg|
      f = File.new(File.join(AdminDataConfig.setting[:plugin_dir],'lib','css',"#{arg}.css"))
      tmp << f.read
    end
    tmp << '</style>'
    tmp.join
  end

  def self.get_class_name_for_has_many_association(model,belongs_to_string)
    begin
      tmp = model.send(belongs_to_string.intern)
      tmp.find(:first).class if tmp.count > 0
    rescue
      nil
    end
  end

  def self.get_class_name_for_belongs_to_class(model,belongs_to_string)
    begin
      tmp = model.send(belongs_to_string.intern)
      tmp.class.to_s if tmp
    rescue
      nil
    end
  end

  def self.has_many_count(model,hm)
    model.send(hm.intern).count
  end

  def self.has_many_what(klass)
    output = []
    klass.name.camelize.constantize.reflections.each do |key,value|
      output << value.name.to_s if value.macro.to_s == 'has_many'
    end
    output
  end

  def self.has_one_what(klass)
    output = []
    klass.name.camelize.constantize.reflections.each do |key,value|
      output << value.name.to_s if value.macro.to_s == 'has_one'
    end
    output
  end

  def self.belongs_to_what(klass)
    # is it possible to user inject here to ge rid of output
    output = []
    klass.name.camelize.constantize.reflections.each do |key,value|
      output << value.name.to_s if value.macro.to_s == 'belongs_to'
    end
    output
  end

  def self.admin_data_association_info_size(klass)
    (belongs_to_what(klass).size > 0)  ||
    (has_many_what(klass).size > 0) ||
    (has_one_what(klass).size > 0)
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

  def self.build_sort_options(klass,sortby)
   klass.columns.inject([]) do |result,column|
      name = column.name

      selected_text = sortby == "#{name} desc" ? "selected='selected'" : ''
      result << "<option value='#{name} desc' #{selected_text}>&nbsp;#{name} desc</option>"

      selected_text = sortby == "#{name} asc" ? "selected='selected'" : ''
      result << "<option value='#{name} asc' #{selected_text}>&nbsp;#{name} asc</option>"
    end
  end

end
