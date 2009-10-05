module AdminData::Helpers

  def breadcrum(&block)
    partial_value = render(:partial => '/admin_data/main/misc/breadcrum', :locals => {:data => capture(&block)}) 
    concat(partial_value)
  end

  def admin_data_form_field(klass, model, col, f)
    html = []

    if klass.serialized_attributes.has_key?(col.name)
      html << %{ <i>Cannot edit serialized field.</i> }
      unless model.send(col.name).blank?
        html << %{ <i>Raw contents:</i><br/> }
        html << model.send(col.name).inspect
      end
      return html.join
    end

    uscore_name = klass.name.underscore
    if col.primary 
      html <<  model.new_record? ? '(auto)' : model.id

    elsif reflection = klass.reflections.values.detect {|reflection| reflection.primary_key_name.to_sym == col.name.to_sym}
      #foreign key
      association_name = reflection.klass.columns.map(&:name).include?('name') ? :name : reflection.klass.primary_key
      all_for_dropdown = reflection.klass.all(:order => "#{association_name} asc")
      html << f.collection_select(col.name, all_for_dropdown, :id, association_name, :include_blank => true) 

    elsif col.type == :text
      html << f.text_area(col.name, :rows => 6, :cols => 70)

    elsif col.type == :datetime && ['created_at', 'updated_at'].include?(col.name)
      html <<  model.new_record? ? '(auto)' : model.send(col.name)

    elsif col.type == :datetime
      value = model.send(col.name) 
      value = Time.now if params[:action] == 'new'
      year_value = value.year if value
      html << text_field_tag("#{klass.name.underscore}[#{col.name}(1i)]", year_value, :class => 'nice-field')
      html << f.datetime_select(col.name, :discard_year => true) 
    
    elsif col.type == :date
      value = model.send(col.name) 
      value = Time.now if params[:action] == 'new'
      year_value = value.year if value
      html << text_field_tag("#{klass.name.underscore}[#{col.name}(1i)]", year_value, :class => 'nice-field')
      html << f.date_select(col.name)
    
    elsif col.type == :time
      value = model.send(col.name) 
      value = Time.now if params[:action] == 'new'
      html << f.time_select(col.name, :discard_year => true) 

    elsif col.type == :boolean
      html << f.select(col.name, [['True', true], ['False', false]], :include_blank => true)

    else
      col_limit = col.limit || 255
      size = (col_limit < 56) ? col_limit : 56
      options = {:size => size, :class => 'nice-field'}
      options[:maxlength] = col.limit if col.limit
      html << f.text_field(col.name, options)
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

end
