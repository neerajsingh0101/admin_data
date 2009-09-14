module AdminData::Helpers

  def admin_data_form_field(klass,model,col)
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
    if col.name == 'id'
      html<<  model.new_record? ? '(auto)' : model.id

    elsif col.type == :text
      html << "<textarea rows='6' cols='70' name='#{uscore_name}[#{col.name}]'>"
      html << model.send(col.name)
      html << '</textarea>'

    elsif col.type == :datetime && ['created_at', 'updated_at'].include?(col.name)
      html <<  model.new_record? ? '(auto)' : model.send(col.name)

    elsif col.type == :datetime
      value = model.send(col.name)
      value = value.send(:to_s, :db) if value
      value = Time.now.to_s(:db) if params[:action] == 'new'
      html << text_field(klass.name.underscore, col.name, :value => value, :class => 'nice-field')

    elsif col.type == :boolean
      html << "<select id='#{uscore_name}_#{col.name}' name='#{uscore_name}[#{col.name}]'>"
      html <<  "<option value=''></option>"

      if model.send(col.name)
        html << %{ <option value='true' 'selected'>True</option> }
      else
        html << %{ <option value='true'>True</option> }
      end

      if !model.send(col.name)
        html << %{ <option value='false' 'selected'>False</option> }
      else
        html << %{ <option value='false'>False</option> }
      end

      html << '</select>'

    else
      col_limit = col.limit || 255
      size = (col_limit < 56) ? col_limit : 56
      if col.limit
        html << text_field(klass.to_s.underscore, col.name, :value => model.send(col.name),
        :size => size, :maxlength => col.limit, :class => 'nice-field')

      else
        html << text_field(klass.to_s.underscore, col.name, :value => model.send(col.name),
        :size => size, :class => 'nice-field')
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

end
