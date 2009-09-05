module AdminData::Helpers

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

end
