module AdminData
  class Util

    def self.label_values_pair_for(model, view)
      data = model.class.columns.inject([]) do |sum, column|
        tmp = view.get_value_for_column(column, model, :limit => nil)
        sum << [ column.name, (tmp.html_safe? ? tmp : view.send(:h,tmp)) ]
      end
      data
    end

    def self.custom_value_for_column(column, model)
      # some would say that if I use try method then I will not be raising exception and
      # I agree. However in this case for clarity I would prefer to not to have try after each call
      begin
        column_name = column.respond_to?(:name) ? column.name : column
        tmp = AdminData.config.column_settings[model.class.name.to_s]
        _proc = tmp.fetch(column_name.intern)
        _proc.call(model)
      rescue
        model.send(column_name)
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

    # Usage: write 'hello world' to tmp/hello.txt file
    # Util.write_to_file('hello world', 'a+', 'tmp', 'hello.txt')
    def self.write_to_file(data, mode, *path)
      path = File.expand_path(Rails.root.join(*path.flatten.compact))
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, mode) {|fh| fh.puts(data) }
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
end
