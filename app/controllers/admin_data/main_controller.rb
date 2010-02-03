class AdminData::MainController  < AdminData::BaseController

  unloadable

  before_filter :get_class_from_params, :only => [ :table_structure, :show, :destroy, :del, :edit, :new, :update, :create]

  before_filter :ensure_is_allowed_to_view

  before_filter :get_model_and_verify_it, :only => [:destroy, :del, :edit, :update, :show]

  before_filter :ensure_is_allowed_to_view_model, :except => [:all_models, :index]

  before_filter :ensure_is_allowed_to_update, :only => [:destroy, :del, :edit, :update, :create]

  before_filter :ensure_is_allowed_to_update_model, :only => [:destroy, :del, :edit, :update, :create]


  def table_structure
    @page_title = 'table_structure'
    @indexes = []
    if (indexes = ActiveRecord::Base.connection.indexes(@klass.table_name)).any?
      add_index_statements = indexes.map do |index|
        statment_parts = [ ('add_index ' + index.table.inspect) ]
        statment_parts << index.columns.inspect
        statment_parts << (':name => ' + index.name.inspect)
        statment_parts << ':unique => true' if index.unique

        '  ' + statment_parts.join(', ')
      end
      add_index_statements.sort.each { |index| @indexes << index }
    end
    respond_to {|format| format.html}
  end

  def all_models
    respond_to {|format| format.html}
  end

  def show
    @page_title = "#{@klass.name.underscore}:#{@model.id}"
    respond_to {|format| format.html}
  end

  def destroy
    @klass.send(:destroy, params[:id])
    redirect_to admin_data_search_path(:klass => @klass.name.underscore)
  end

  def del
    @klass.send(:delete, params[:id])
    flash[:success] = 'Record was deleted'
    redirect_to admin_data_search_path(:klass => @klass.name.underscore)
  end

  def edit
    @page_title = "edit #{@klass.name.underscore}:#{@model.id}"
    @columns = columns_list
    respond_to {|format| format.html}
  end

  def new
    @page_title = "new #{@klass.name.underscore}"
    @model = @klass.send(:new)
    @columns = columns_list
    respond_to {|format| format.html}
  end

  def update
    model_name_underscored = @klass.name.underscore
    model_attrs = params[model_name_underscored]
    @columns = columns_list
    respond_to do |format|
      if @model.update_attributes(model_attrs)
        format.html do
          flash[:success] = "Record was updated"
          redirect_to admin_data_on_k_path(:id => @model, :klass => @klass.name.underscore)
        end
        format.js { render :json => {:success => true}}
      else
        format.html { render :action => 'edit' }
        format.js { render :json => {:error => @model.errors.full_messages.join } }
      end
    end
  end

  def create
    model_name_underscored = @klass.name.underscore
    model_attrs = params[model_name_underscored]
    @model = @klass.create(model_attrs)
    @columns = columns_list

    respond_to do |format|
      if @model.errors.any?
        format.html { render :action => 'new' }
        format.js { render :json => {:error => @model.errors.full_messages.join() }}
      else
        format.html do
          flash[:success] = "Record was created"
          redirect_to admin_data_on_k_path(:id => @model, :klass => @klass.name.underscore)
        end
        format.js { render :json => {} }
      end
    end
  end

  private

  def get_model_and_verify_it
    primary_key = @klass.primary_key.intern
    conditional_id = params[:id] =~ /^(\d+)-.*/ ? params[:id].to_i : params[:id]
    condition = {primary_key => conditional_id}

    # http://neerajdotname.github.com/admin_data/#override_find_condition
    find_conditions_proc = AdminDataConfig.setting[:find_conditions] ?  AdminDataConfig.setting[:find_conditions][@klass.name] : nil
    if find_conditions_proc && find_conditions = find_conditions_proc.call(params)

      if find_conditions.has_key?(:conditions)
        condition = find_conditions.fetch(:conditions)
      end
    end

    @model = @klass.send('find', :first, :conditions => condition)
    unless @model
      render :text => "<h2>#{@klass.name} not found: #{params[:id]}</h2>", :status => :not_found
    end
  end

  def columns_list
    params[:attr].blank? ? @klass.columns : @klass.columns.find_all {|col| params[:attr] == col.name}
  end

end
