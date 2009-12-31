class AdminData::Util

  # Rails method merge_conditions ANDs all the conditions. I need to ORs all the conditions 
  def self.or_merge_conditions(klass, *conditions)
   segments = []
   conditions.each do |condition|
      unless condition.blank?
         sql = klass.send(:sanitize_sql, condition)
         segments << sql unless sql.blank?
      end
   end
   "(#{segments.join(') OR (')})" unless segments.empty?
  end

  # klass_name = model_name.sub(/\.rb$/,'').camelize
  # constantize_klass(klass_name)
  def self.constantize_klass(klass_name)
    klass_name.split('::').inject(Object) do |klass, part|
      klass.const_get(part)
    end
  end

  def self.columns_order(klass_s)
    klass = self.constantize_klass(klass_s)
    columns = klass.columns.map(&:name)
    columns_symbol = columns.map(&:intern)

    columns_order = AdminDataConfig.setting[:columns_order]

    if columns_order && columns_order.has_key?(klass_s) && columns_order.fetch(klass_s)
      primary_key = klass.send(:primary_key).intern
      order = [primary_key] + columns_order.fetch(klass_s)
      order.uniq!
      sanitized_order = order - (order - columns_symbol)
      sorted_columns = sanitized_order + (columns_symbol - sanitized_order)
      sorted_columns.map(&:to_s)
    else
      if columns_symbol.include? :created_at
        columns_symbol = (columns_symbol - [:created_at]) << [:created_at]
      end

      if columns_symbol.include? :updated_at
        columns_symbol = (columns_symbol - [:updated_at]) << [:updated_at]
      end
      columns_symbol.map(&:to_s)
    end
  end

  def self.write_to_validation_file(tid, filename, mode, data)
    file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid , filename)
    File.open(file, mode) {|f| f.puts(data) }
  end

  def self.javascript_include_tag(*args)
    data = args.inject('') do |sum, arg|
      f = File.new(File.join(AdminDataConfig.setting[:plugin_dir],'lib','js',"#{arg}.js"))
      sum << f.read
    end
    ['<script type="text/javascript">', data, '</script>'].join
  end

  def self.stylesheet_link_tag(*args)
    data = args.inject('') do |sum, arg|
      f = File.new(File.join(AdminDataConfig.setting[:plugin_dir],'lib','css',"#{arg}.css"))
      sum << f.read
    end
    ["<style type='text/css'>", data, '</style>'].join
  end

  def self.get_class_name_for_habtm_association(model, habtm_string)
    model.class.reflections.values.detect {|reflection| reflection.name == habtm_string.to_sym}.klass
  end

  def self.get_class_name_for_has_many_association(model, has_many_string)
    data = model.class.name.camelize.constantize.reflections.values.detect do |value|
      value.macro == :has_many && value.name.to_s == has_many_string
    end
    data.klass if data # output of detect from hash is an array with key and value
  end

  def self.get_class_name_for_belongs_to_class(model, belongs_to_string)
    reflections = model.class.name.camelize.constantize.reflections
    options = reflections.fetch(belongs_to_string.intern).send(:options)
    return {:polymorphic => true} if options.keys.include?(:polymorphic) && options.fetch(:polymorphic)
    {:klass_name => reflections[belongs_to_string.intern].klass.name }
  end

  def self.get_class_name_for_has_one_class(model, has_one_string)
    data = model.class.name.camelize.constantize.reflections.values.detect do |value|
      value.macro == :has_one && value.name.to_s == has_one_string
    end
    data.klass if data
  end

  def self.has_many_count(model, hm)
    Rails.logger.debug "has_many_count: model is #{model.inspect} hm is #{hm.inspect}" if $debug_admin_data
    model.send(hm.intern).count
  end

  def self.habtm_count(model, habtm)
    has_many_count(model, habtm)
  end

  def self.has_many_what(klass)
    associations_for(klass, :has_many).map(&:name).map(&:to_s)
  end

  def self.has_one_what(klass)
    associations_for(klass, :has_one).map(&:name).map(&:to_s)
  end

  def self.belongs_to_what(klass)
    associations_for(klass, :belongs_to).map(&:name).map(&:to_s)
  end

  def self.habtm_what(klass)
    associations_for(klass, :has_and_belongs_to_many).map(&:name).map(&:to_s)
  end

  def self.admin_data_association_info_size(klass)
    (belongs_to_what(klass).size > 0)  ||
    (has_many_what(klass).size > 0) ||
    (has_one_what(klass).size > 0) ||
    (habtm_what(klass).size > 0)
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
    klass.columns.inject([]) do |result,column|
      name = column.name

      selected_text = sortby == "#{name} desc" ? "selected='selected'" : ''
      result << "<option value='#{name} desc' #{selected_text}>&nbsp;#{name} desc</option>"

      selected_text = sortby == "#{name} asc" ? "selected='selected'" : ''
      result << "<option value='#{name} asc' #{selected_text}>&nbsp;#{name} asc</option>"
    end
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
