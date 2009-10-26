module AdminData::Helpers

  def breadcrum(&block)
    partial_value = render(:partial => '/admin_data/main/misc/breadcrum', :locals => {:data => capture(&block)}) 
    concat(partial_value)
  end

  def admin_data_form_field(klass, model, col, f)
    html = []
    column_value = model.send(col.name)

    if klass.serialized_attributes.has_key?(col.name)
      return get_serialized_value(html,column_value)
    end

    if col.primary 
      html <<  model.new_record? ? '(auto)' : model.id

    elsif reflection = klass.reflections.values.detect { |reflection| 
                                             reflection.primary_key_name.to_sym == col.name.to_sym
                                             }
      ref_klass = reflection.klass
      association_name = ref_klass.columns.map(&:name).include?('name') ? :name : ref_klass.primary_key
      all_for_dropdown = ref_klass.all(:order => "#{association_name} asc")
      html << f.collection_select(col.name, all_for_dropdown, :id, association_name, :include_blank => true) 

   else
      case col.type
      when :text
         html << f.text_area(col.name, :rows => 6, :cols => 70)
      when :datetime
         if ['created_at', 'updated_at'].include?(col.name)
            html <<  model.new_record? ? '(auto)' : column_value
         else 
            value = params[:action] == 'new' ? Time.now : column_value
            year_value = value.year if value
            html << text_field_tag("#{klass.name.underscore}[#{col.name}(1i)]", year_value, :class => 'nice-field')
            html << f.datetime_select(col.name, :discard_year => true) 
         end

      when :date
         value = Time.now params[:action] == 'new' ? Time.now : column_value
         year_value = value.year if value
         html << text_field_tag("#{klass.name.underscore}[#{col.name}(1i)]", year_value, :class => 'nice-field')
         html << f.date_select(col.name)

      when :time
         html << f.time_select(col.name, :discard_year => true) 

      when :boolean
         html << f.select(col.name, [['True', true], ['False', false]], :include_blank => true)

      else
         col_limit = col.limit || 255
         size = (col_limit < 56) ? col_limit : 56
         options = {:size => size, :class => 'nice-field'}
         options[:maxlength] = col.limit if col.limit
         html << f.text_field(col.name, options)
      end
    end
  end


  # using params[:controller]
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


  # uses truncate method
  # options supports :limit which is applied if the column type is string or text
  def admin_data_get_value_for_column(column, source, options = {})
    options.reverse_merge!(:limit => 400)
    value = source.send(column.name)
    if column.type == :datetime
      value.strftime('%m/%d/%Y %H:%M:%S %p') unless value.blank?
    elsif column.type == :string || column.type == :text
      return value if options[:limit].blank?
      # truncate method fails in handling serialized array stored in string column
      begin
        truncate(value,:length => options[:limit])
      rescue
        '<actual data is not being shown because truncate method failed.>'
      end
    else
      value
    end
  end

  private

  def get_serialized_value(html, column_value)
    html << %{ <i>Cannot edit serialized field.</i> }
    unless column_value.blank?
      html << %{ <i>Raw contents:</i><br/> }
      html << column_value.inspect
    end
    html.join
  end

end
