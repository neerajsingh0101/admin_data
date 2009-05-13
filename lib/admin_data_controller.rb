class AdminDataController  < ApplicationController
  
  unloadable
  
  before_filter :ensure_is_allowed_to_view
  before_filter :admin_data_is_allowed_to_update?, :only => [:destroy, :delete, :edit]
  before_filter :get_class_from_params, :only => [:table_structure,:quick_search,:advance_search,:list,:show,:destroy,:delete,:edit,:new,:update,:create]

  def migration_information
    @data = ActiveRecord::Base.connection.select_all('select * from schema_migrations');
    render :file =>   "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/migration_information.html.erb"        
  end
  
  def table_structure
    @types = ActiveRecord::Base.connection.native_database_types    

    if ActiveRecord::Base.connection.respond_to?(:pk_and_sequence_for)
      pk, pk_seq = ActiveRecord::Base.connection.pk_and_sequence_for(@klass.table_name)
    end
    pk ||= 'id'

    column_specs = @klass.columns.map do |column|
      raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'" if @types[column.type].nil?
      next if column.name == pk
      spec = {}
      spec[:name]      = column.name.inspect
      spec[:type]      = column.type.to_s
      spec[:limit]     = column.limit.inspect if column.limit != @types[column.type][:limit] && column.type != :decimal
      spec[:precision] = column.precision.inspect if !column.precision.nil?
      spec[:scale]     = column.scale.inspect if !column.scale.nil?
      spec[:null]      = 'false' if !column.null
      spec[:default]   = default_string(column.default) if column.has_default?
      (spec.keys - [:name, :type]).each{ |k| spec[k].insert(0, "#{k.inspect} => ")}
      spec
    end.compact

    # find all migration keys used in this table
    keys = [:name, :limit, :precision, :scale, :default, :null] & column_specs.map(&:keys).flatten

    # figure out the lengths for each column based on above keys
    lengths = keys.map{ |key| column_specs.map{ |spec| spec[key] ? spec[key].length + 2 : 0 }.max }

    # the string we're going to sprintf our values against, with standardized column widths
    format_string = lengths.map{ |len| "%-#{len}s" }

    # find the max length for the 'type' column, which is special
    type_length = column_specs.map{ |column| column[:type].length }.max

    # add column type definition to our format string
    format_string.unshift "    %-#{type_length}s "

    format_string *= ''

    @records = []
    column_specs.each do |colspec|
      values = keys.zip(lengths).map{ |key, len| colspec.key?(key) ? colspec[key] + ", " : " " * len }
      values.unshift colspec[:type]
      @records << ((format_string % values).gsub(/,\s*$/, ''))
    end
    
    if (indexes = ActiveRecord::Base.connection.indexes(@klass.table_name)).any?
      add_index_statements = indexes.map do |index|
        statment_parts = [ ('add_index ' + index.table.inspect) ]
        statment_parts << index.columns.inspect
        statment_parts << (':name => ' + index.name.inspect)
        statment_parts << ':unique => true' if index.unique

        '  ' + statment_parts.join(', ')
      end
      @records << ""
      add_index_statements.sort.each { |index| @records << index }
    end  
    
    render :file =>   "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/table_structure.html.erb"        
  end

  def quick_search
    session[:admin_data_search_type] = 'quick'          
    params[:query] = params[:query].strip
    
    if params[:query].blank?
      @records = @klass.send( :paginate,
                              :page => params[:page],
                              :order => "#{@klass.table_name}.id desc",
                              :per_page => 25)            
    else
      @records = @klass.paginate( :page => params[:page],
                                  :per_page => 25,
                                  :order => "#{@klass.table_name}.id desc",
                                  :conditions => build_quick_search_conditions(@klass,params[:query]))
    end
    
    render :file =>   "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/list.html.erb"    
  end
  
  
  def advance_search
    session[:admin_data_search_type] = 'advance'
        
    if !params[:adv_search].blank?
      @records = @klass.paginate( :page => params[:page],
                                  :per_page => 25,
                                  :order => "#{@klass.table_name}.id desc",
                                  :conditions => build_advance_search_conditions(@klass,params[:adv_search]))
    else
      @records = @klass.send( :paginate,
                              :page => params[:page],
                              :per_page => 25,
                              :order => "#{@klass.table_name}.id desc")      
    end
        
    respond_to do |format|
        format.html {
          render :file =>   "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/list.html.erb"               
        }
        format.js {
          render :file => "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/_search_results.html.erb"               
        }
      end
  end
  
  def index
    @klasses = []
    models = []

    model_dir = File.join(RAILS_ROOT,'app','models')
    Dir.chdir(model_dir) { models = Dir["**/*.rb"] }
    
    models = models.sort
    
    models.each do |model|
      class_name = model.sub(/\.rb$/,'').camelize      
      begin
        # for models/foo/bar/baz.rb
        klass = class_name.split('::').inject(Object){ |klass,part| klass.const_get(part) } 
      rescue Exception
      end
      if klass && klass.ancestors.include?(ActiveRecord::Base)  && !@klasses.include?(klass)
        # it is possible that a model doesnot have a table because migration has not been run or
        # migration has deleted the table but the model has not been deleted. So remove those classes from the list
        # I will send a count method to determine if a table is existing or not
        begin
          klass.send(:count)
          @klasses << klass 
        rescue ActiveRecord::StatementInvalid  => e
        end
      end
    end
    render :file =>   "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/index.html.erb"
  end


  def list
    if params[:base]
      model= Object.const_get(params[:base]).find(params[:model_id])
      has_many_proxy = model.send(params[:send].intern)
      @records = has_many_proxy.send( :paginate,
                                      :page => params[:page],
                                      :per_page => 25,
                                      :order => "#{@klass.table_name}.id desc")            
    else
      @records = @klass.send( :paginate,
                              :page => params[:page],
                              :per_page => 25,
                              :order => "#{@klass.table_name}.id desc")
    end
    session[:admin_data_search_type] = nil 
    render :file =>   "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/list.html.erb"    
  end

  
  def show
    admin_data_is_allowed_to_update?
    @model = @klass.send(:find,params[:model_id]) rescue nil
    render :text => "<h2>#{@klass_name} Not Found: #{params[:model_id]}</h2>", :status => 404 and return if @model.nil?
    render :file =>   "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/show.html.erb"        
  end
  
  def destroy
    @model = @klass.send(:find,params[:model_id]) rescue nil
    render :text => "<h2>#{@klass_name} Not Found: #{params[:model_id]}</h2>", :status => 404 and return if @model.nil?
    
    @klass.send(:destroy,params[:model_id])
    flash[:success] = 'Record was destroyed'
    redirect_to admin_data_list_path(:klass => @klass.name)    
  end

  def delete
    @model = @klass.send(:find,params[:model_id]) rescue nil
    render :text => "<h2>#{@klass_name} Not Found: #{params[:model_id]}</h2>", :status => 404 and return if @model.nil?
    
    @klass.send(:delete,params[:model_id])
    flash[:success] = 'Record was deleted'
    redirect_to admin_data_list_path(:klass => @klass.name)    
  end
  
  def edit
    @model = @klass.send(:find,params[:model_id]) rescue nil
    render :text => "<h2>#{@klass_name} Not Found: #{params[:model_id]}</h2>", :status => 404 and return if @model.nil?
    render :file =>   "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/edit.html.erb"        
  end



  def new
    @model = @klass.send(:new) 
    render :file =>   "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/new.html.erb"        
  end
  
  def update
    @model = @klass.send(:find,params[:model_id]) rescue nil
    render :text => "<h2>#{@klass_name} Not Found: #{params[:model_id]}</h2>", :status => 404 and return if @model.nil?
        
    model_name_underscored = @klass.to_s.underscore
    
    model_attrs = params[model_name_underscored]
    
    if @model.update_attributes(model_attrs)
      flash[:success] = "Record was Updated"
      redirect_to admin_data_show_path(:model_id => @model.id, :klass => @klass.to_s)
    else
      render :file =>   "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/edit.html.erb"              
    end
  end
  
  def create
    model_name_underscored = @klass.to_s.underscore
    model_attrs = params[model_name_underscored]
    @model = @klass.create(model_attrs)
    if @model.errors.any?
      render :file =>   "#{RAILS_ROOT}/vendor/plugins/admin_data/lib/views/new.html.erb"                    
    else
      flash[:success] = "Record was created"
      redirect_to admin_data_show_path(:model_id => @model.id, :klass => @klass.to_s)
    end
  end
  
  #-------
  private
  #-------
   
  def ensure_is_allowed_to_view
    render :text => 'You are not authorized' unless admin_data_is_allowed_to_view?
  end
   
  def build_quick_search_conditions(klass,search_term)
    like_operator = 'LIKE'
    like_operator = 'ILIKE' if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
    
    attribute_conditions = []    
    klass.columns.each do |column|
      if %w(string text).include? column.type.to_s
        attribute_conditions << "#{table_name_and_attribute_name(klass,column)} #{like_operator} :search_term"
      end
    end

    condition = attribute_conditions.join(' or ')
    [condition, {:search_term => "%#{search_term.downcase}%"}]
  end
  
  def build_advance_search_conditions(klass,search_options)
    attribute_conditions = []    
    terms = {}    
    
    search_options.each do |key,value|
      col1 = value[:col1]
      col2 = value[:col2]
      col3 = value[:col3]
      col3.strip! if !col3.blank?
      col3 = col3.downcase if !col3.blank?
      
      tmp_key = 'tmp'+key.to_s
      
      
      like_operator = 'LIKE'
      like_operator = 'ILIKE' if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      
      case col2
      when 'contains':
        attribute_conditions << ["#{klass.table_name}.#{col1} #{like_operator} ?","%#{col3}%"] if !col3.blank?
      when 'is_exactly':
        attribute_conditions << ["#{klass.table_name}.#{col1} = ?",col3] if !col3.blank?
      when 'does_not_contain':
        attribute_conditions << ["#{klass.table_name}.#{col1} NOT #{like_operator} ?","%#{col3}%"] if !col3.blank?        
      when 'is_false':
        attribute_conditions << ["#{klass.table_name}.#{col1} = ?",false]                  
      when 'is_true':  
        attribute_conditions << ["#{klass.table_name}.#{col1} = ?",true]        
      when 'is_null':  
        attribute_conditions << "#{klass.table_name}.#{col1} IS NULL"        
      when 'is_not_null':
        attribute_conditions << "#{klass.table_name}.#{col1} IS NOT NULL"        
      when 'is_on':
        if (time_obj = AdminDataDateValidation.validate_with_operator(col3))
          attribute_conditions << ["#{klass.table_name}.#{col1} >= ?",time_obj.beginning_of_day]
          attribute_conditions << ["#{klass.table_name}.#{col1} < ?",time_obj.end_of_day]
        end
      when 'is_on_or_before_date':
        if (time_obj = AdminDataDateValidation.validate_with_operator(col3))
          attribute_conditions << ["#{klass.table_name}.#{col1} <= ?",time_obj.end_of_day]
        end
      when 'is_on_or_after_date':
        if (time_obj = AdminDataDateValidation.validate_with_operator(col3))
          attribute_conditions << ["#{klass.table_name}.#{col1} >= ?",time_obj.beginning_of_day]
        end

      when 'is_equal_to':
        attribute_conditions << ["#{klass.table_name}.#{col1} = ?",col3.to_i] if !col3.blank?

      when 'greater_than':
        attribute_conditions << ["#{klass.table_name}.#{col1} > ?",col3.to_i] if !col3.blank?                           

      when 'less_than':
        attribute_conditions << ["#{klass.table_name}.#{col1} < ?",col3.to_i] if !col3.blank?                           
      end
      
    end # end of search_options loop
    
    # queries are joined by AND 
    condition = klass.send(:merge_conditions,*attribute_conditions)
    condition
  end
  

  def table_name_and_attribute_name(klass,column)
      table_name_and_attribute_name =  klass.table_name+'.'+column.name    
  end
  
  def default_string(value)
    case value
    when BigDecimal
      value.to_s
    when Date, DateTime, Time
      "'#{value.to_s(:db)}'"
    else
      value.inspect
    end
  end
  
  def get_class_from_params
    begin
      @klass = Object.const_get(params[:klass])
    rescue TypeError # in case no params[:klass] is supplied
      redirect_to admin_data_path
    rescue NameError # in case wrong params[:klass] is supplied
      redirect_to admin_data_path
    end
  end
  
  
end