module AdminData::Helpers

  def admin_data_invalid_record_link(klassu, id, error)
   record = klassu.camelize.constantize.send(:find, id) 
   tmp = admin_data_on_k_path(:klass => klasss.underscore, :id => record) 
   a = []
   a << link_to(klasss, tmp, :target => '_blank') 
   a << id
   a << error
   a.join(' | ')
  end

  def admin_data_has_one(model, klass)
    AdminData::Util.has_one_what(klass).inject('') do |output, ho|
      begin
        if model.send(ho)
          output << link_to(ho, admin_data_on_k_path(:klass => ho.underscore, :id => model.send(ho)))
        else
          output << ho
        end
      rescue => e
        Rails.logger.debug AdminData::Util.exception_info(e)
      end
      output
    end
  end

  def admin_data_has_many_data(model, klass)
    array = AdminData::Util.has_many_what(klass).inject([]) do |output, hm| 
      begin
        label = hm + '(' + AdminData::Util.has_many_count(model,hm).to_s + ')' 
        if AdminData::Util.has_many_count(model,hm) > 0 
          has_many_klass_name = AdminData::Util.get_class_name_for_has_many_association(model,hm).name.underscore 
          output << link_to(label, admin_data_search_path(:klass => has_many_klass_name,
                                                          :children => hm,
                                                          :base => klass.name.underscore, 
                                                          :model_id => model.id))        
        else
          output << label      
        end
      rescue => e 
        Rails.logger.debug AdminData::Util.exception_info(e)
      end
      output
    end  
    array.join(', ')
  end

  def admin_data_belongs_to_data(model, klass)
    array = AdminData::Util.belongs_to_what(klass).inject([]) do |output, bt|
      begin
        t = AdminData::Util.get_class_name_for_belongs_to_class(model, bt)
        klass_name = t[:polymorphic] ? 'Polymorphic' : t[:klass_name]
        belongs_to_record = model.send(bt)

        if belongs_to_record && t[:polymorphic] 
          output << link_to(belongs_to_record.class.name, 
                            admin_data_on_k_path(:klass => belongs_to_record.class.name.underscore,
                                                 :id => belongs_to_record))
        elsif belongs_to_record
          output << link_to(bt, admin_data_on_k_path(:klass => klass_name.underscore,:id => model.send(bt)))
        else
          output << bt
        end
      rescue => e
        Rails.logger.info AdminData::Util.exception_info(e)
      end
      output
    end 
    array.join(', ')
  end

  def admin_data_breadcrum(&block)
    partial_value = render(:partial => '/admin_data/shared/breadcrum', :locals => {:data => capture(&block)})
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

      # in some edge cases following code throws exception. I am working on it.
      # In the meantime I am putting a rescue block
      begin
         options = reflection.options
         if options.keys.include?(:polymorphic) && options.fetch(:polymorphic)
            html << f.text_field(col.name)
         else
            ref_klass = reflection.klass
            association_name = ref_klass.columns.map(&:name).include?('name') ? :name : ref_klass.primary_key
            all_for_dropdown = ref_klass.all(:order => "#{association_name} asc")
            html << f.collection_select(col.name, all_for_dropdown, :id, association_name, :include_blank => true)
         end
      rescue Exception => e
         Rails.logger.info AdminData::Util.exception_info(e)
         'could not retrieve' # returning nil
      end

    else
      handle_column_type(col, html, model, column_value, f)
    end
  end

  def handle_column_type(col, html, model, column_value, f)
    case col.type
    when :text
      html << f.text_area(col.name, :rows => 6, :cols => 70)

    when :datetime
      if ['created_at', 'updated_at'].include?(col.name)
        html <<  model.new_record? ? '(auto)' : column_value
      else
        value = params[:action] == 'new' ? Time.now : column_value
        year_value = value.year if value
        datetime_selects = f.datetime_select(col.name, :include_blank => true)
        html << datetime_selects.gsub('type="hidden"', 'type="text" size="4" class="nice-field"')
      end

    when :date
      value = params[:action] == 'new' ? Time.now : column_value
      year_value = value.year if value
      date_selects = f.date_select(col.name, :discard_year => true, :include_blank => true)
      html << date_selects.gsub('type="hidden"', 'type="text" size="4" class="nice-field"')

    when :time
      # time_select method of rails is buggy and is causing problem
      # 1 error(s) on assignment of multiparameter attributes
      #
      # will try again this method with Rails 3
      #html << f.time_select(col.name, :include_blank => true, :include_seconds => true)

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


   # using params[:controller]
   # Usage:
   #
   # admin_data_am_i_active(['main','index'])
   # admin_data_am_i_active(['main','index list'])
   # admin_data_am_i_active(['main','index list'],['search','advance_search'])
   def admin_data_am_i_active(*args)
      args.each do |arg|
         controller_name = arg[0]
         action_names = arg[1].split
         is_action_included = action_names.include?(params[:action])
         if params[:controller] == "admin_data/#{controller_name}" && is_action_included
            return 'active'
            break
         end
      end
      ''
   end

   def admin_data_get_custom_value_for_column(column, model)
      # some would say that if I use try method then I will not be raising exception and
      # I agree. However in this case for clarity I would prefer to not to have try after each call
      begin
         AdminDataConfig.setting[:column_settings].fetch(model.class.name.to_s).fetch(column.name.intern).call(model)
      rescue
         model.send(column.name)
      end
   end

   # uses truncate method
   # options supports :limit which is applied if the column type is string or text
   def admin_data_get_value_for_column(column, model, options = {})
      options.reverse_merge!(:limit => 400)

      value = admin_data_get_custom_value_for_column(column, model)

      if column.type == :datetime
         value.strftime('%d-%B-%Y %H:%M:%S %p') unless value.blank?
      elsif column.type == :string || column.type == :text
         return value if options[:limit].blank?
         begin
            truncate(value,:length => options[:limit])
         rescue # truncate method fails in handling serialized array stored in string column
            '<actual data is not being shown because truncate method failed.>'
         end
      else
         value
      end
   end

   def admin_data_get_label_values_pair_for(model)
      model.class.columns.inject([]) do |sum, column|
         sum << [column.name, h(admin_data_get_value_for_column(column, model, :limit => nil))]
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
