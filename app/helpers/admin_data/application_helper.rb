module AdminData
  module ApplicationHelper

    def parent_layout(layout)
      @_content_for[:layout] = self.output_buffer
      self.output_buffer = render(:file => "layouts/#{layout}")
    end

    def column_title(klass, column)
      AdminData.config.column_headers[klass.name].try(:fetch,column.intern, nil) || column
    end

    # AdminData.config.columns_order might not list all the columns of a given table. However
    # the listed columns should be at the front in the order mentioned. Primary key will also
    # be the first column. Consumer might define a new column name that is not listed a column.
    #
    def columns_order(klass)
      columns_symbol = klass.columns.map {|e| e.name.intern}

      # created_at and updated_at should be at the very end by default
      if columns_symbol.include? :created_at
        columns_symbol = (columns_symbol - [:created_at]) + [:created_at]
      end
      if columns_symbol.include? :updated_at
        columns_symbol = (columns_symbol - [:updated_at]) + [:updated_at]
      end

      if requested_order = AdminData.config.columns_order[klass.name]
        primary_key = klass.send(:primary_key).intern
        order = [primary_key] + requested_order
        order.uniq!
        # add the columns not covered by user at the end of the list
        sorted_columns = order + (columns_symbol - order)
        sorted_columns.map(&:to_s)
      else
        columns_symbol.map(&:to_s)
      end
    end

    def total_records_info(klass)
      '(Total ' + pluralize(klass.count, 'record') + ' )'
    end

    def search_result_title(total_num_of_children, records)
      output = []
      if params[:base]
        label = params[:base].camelize + ' ID ' + params[:model_id]
        output << link_to(label, admin_data_path(:klass => params[:base], :id => params[:model_id]))
        output << 'has'
        output << pluralize(total_num_of_children, params[:klass])

      elsif !params[:query].blank? || params[:adv_search]
        output << 'Search result:'
        output << pluralize(records.total_entries, 'record')
        output << 'found'

      else
        output << 'All '
        output << params[:klass].camelize
        output << 'records'
      end
      output.join(' ').html_safe
    end

    def column_native(klass, column)
      klass.send(:columns).select {|r| r.instance_variable_get('@name') == column}.first || column
    end

    def has_one(model, klass)
      tmp = ActiveRecordUtil.new(klass).declared_has_one_association_names
      tmp.inject('') do |output, ho|
        begin
          label = ho
          if model.send(ho)
            output << link_to(label, admin_data_path(:klass => ho.underscore, :id => model.send(ho)))
          else
            output << label
          end
        rescue => e
          Rails.logger.debug Util.exception_info(e)
        end
        output
      end
    end

    def has_many_data(model, klass)
      array = ActiveRecordUtil.new(klass).declared_has_many_association_names.map do |m|
        begin
          count = model.send(m.intern).count
          label = m.to_s + '(' + count.to_s + ')'
          output = label
          if count > 0
            has_many_klass_name = ActiveRecordUtil.new(model.class).klass_for_association_type_and_name(:has_many, m).name.underscore
            output = link_to(label, admin_data_search_path(  :klass => has_many_klass_name,
            :children => m,
            :base => klass.name.underscore,
            :model_id => model.id))
          end
        rescue => e
          Rails.logger.debug Util.exception_info(e)
        end
        output
      end
      array.join(', ')
    end

    def belongs_to_data(model, klass)
      ActiveRecordUtil.new(klass).declared_belongs_to_association_names.map do |assoc_name|
        begin
          output = assoc_name
          if belongs_to_record = model.send(assoc_name)
            output = link_to(assoc_name, admin_data_path(:klass => belongs_to_record.class.name.underscore, :id => belongs_to_record.id))
          end
        rescue => e
          Rails.logger.info Util.exception_info(e)
        end
        output
      end.join(', ')
    end

    def habtm_data(model, klass)
      ActiveRecordUtil.new(klass).declared_habtm_association_names.map do |assoc_name|
        begin
          count = model.send(assoc_name.intern).count
          label = assoc_name + '(' + count.to_s + ')'
          output = label

          if count > 0 then
            has_many_klass_name = ActiveRecordUtil.new(model.class).klass_for_association_type_and_name(:has_and_belongs_to_many, assoc_name).name.underscore
            output = link_to(label, admin_data_search_path(  :klass => has_many_klass_name,
            :children => assoc_name,
            :base => klass.name.underscore,
            :model_id => model.id))
          end
        rescue => e
          Rails.logger.info Util.exception_info(e)
        end
        output
      end.join(', ')
    end

    def breadcrum(&block)
      render(:partial => '/admin_data/shared/breadcrum', :locals => {:data => capture(&block)})
    end

    def form_field(klass, model, col, f)
      html = []
      column_value = model.send(col.name)

      if klass.serialized_attributes.has_key?(col.name)
        return Util.get_serialized_value(html,column_value)
      end

      if col.primary
        html <<  model.new_record? ? '(auto)' : model.id
      elsif get_reflection_for_column(klass, col) && AdminData.config.display_assoc?( klass.name )
        form_field_for_association_records(klass, col, f, html)
      else
        handle_column_type(col, html, model, column_value, f)
      end
    end


    def form_field_for_association_records(klass, col, f, html)
      begin
        reflection = get_reflection_for_column(klass, col)

        # in some edge cases following code throws exception. investigating ..
        options = reflection.options
        if options.keys.include?(:polymorphic) && options.fetch(:polymorphic)
          build_text_field(html, f, col)
        else
          ref_klass = reflection.klass
          association_name = ref_klass.columns.map(&:name).include?('name') ? :name : ref_klass.primary_key
          all_for_dropdown = ref_klass.all(:order => "#{association_name} asc")
          html << f.collection_select(col.name, all_for_dropdown, :id, association_name, :include_blank => true)
        end
        html.join
      rescue Exception => e
        Rails.logger.info Util.exception_info(e)
        'could not retrieve' # returning nil
      end
    end

    def form_field_for_habtm_records(klass, model, f, html)
      begin
        html = []
        ActiveRecordUtil.new(klass).delcared_habtm_association_names.each do |k|
          assoc_klass = Util.get_class_name_for_habtm_association(model, k)

          html << "<div class='col_box'>"
          html << "  <span class='col_name'>#{assoc_klass.table_name}</span>"
          html << "  <span class='col_type'>[integer]</span>"
          html << "</div>"

          order_by = assoc_klass.columns.map(&:name).include?('name') ? :name : assoc_klass.primary_key
          all = assoc_klass.all(:order => order_by)
          selected = model.send(assoc_klass.table_name).map{|e| e.id}
          html << f.collection_select(assoc_klass.table_name, all, :id, order_by,
          {:include_blank => false, :selected => selected},
          {:multiple => true, :size => (all.count > 10 ? 8 : 4)})
        end
        html.join
      rescue Exception => e
        Rails.logger.info Util.exception_info(e)
        'could not retrieve' # returning nil
      end
    end

    def handle_column_type(col, html, model, column_value, f)
      case col.type
      when :text
        html << f.text_area(col.name, :rows => 6, :cols => 70)

      when :datetime
        if ['created_at', 'updated_at'].include?(col.name)
          html <<  '(auto)'
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
        build_text_field(html, f, col)
      end
      html.join
    end


    def build_text_field(html, f, col)
      options = {:class => 'nice-field'}
      if AdminData.config.ignore_column_limit
        options[:size] = 60
        options[:maxlength] = 255
      else
        options[:size] = (col && col.limit && col.limit < 60) ? col.limit : 60
        options[:maxlength] = col.limit if col.limit
      end
      html << f.text_field(col.name, options)
      html.join
    end

    # uses truncate method
    # options supports :limit which is applied if the column type is string or text.
    # calls the inspect method to convert to a string if the column is serialized.
    # TODO rspec test limit option
    def get_value_for_column(column, model, options = {})
      options.reverse_merge!(:limit => 400)

      value = Util.custom_value_for_column(column, model)

      if column.is_a?(String)
        value
      elsif column.type == :datetime
        value.strftime('%d-%B-%Y %H:%M:%S %p') unless value.blank?
      elsif column.type == :string || column.type == :text
        value = value.inspect if model.class.serialized_attributes.keys.include?(column.name)
        return value if options[:limit].blank?
        begin
          truncate(value,:length => options[:limit])
        rescue # truncate method failed
          '<actual data is not being shown because truncate method failed.>'
        end
      else
        value.to_s
      end
    end

    def get_reflection_for_column(klass, col)
      klass.reflections.values.detect { |reflection| reflection.primary_key_name.to_sym == col.name.to_sym }
    end

  end
end
