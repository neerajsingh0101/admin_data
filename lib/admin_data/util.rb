class AdminData::Util

  def self.javascript_include_tag(*args)
    data = args.inject('') do |sum, arg|
      f = File.new(File.join(AdminDataConfig.setting[:plugin_dir],'lib','js',"#{arg}.js"))
      sum << f.read
    end
    ['<script>', data, '</script>'].join
  end

  def self.stylesheet_link_tag(*args)
    data = args.inject('') do |sum, arg|
      f = File.new(File.join(AdminDataConfig.setting[:plugin_dir],'lib','css',"#{arg}.css"))
      sum << f.read
    end
    ['<style>', data, '</style>'].join
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
    data = model.class.name.camelize.constantize.reflections.values.detect do |value|
      value.macro == :belongs_to && value.name.to_s == belongs_to_string
    end
    data.klass if data
  end

  def self.get_class_name_for_has_one_class(model, has_one_string)
    data = model.class.name.camelize.constantize.reflections.values.detect do |value|
      value.macro == :has_one && value.name.to_s == has_one_string
    end
    data.klass if data
  end

  def self.has_many_count(model, hm)
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

  def self.build_sort_options(klass,sortby)
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

end
