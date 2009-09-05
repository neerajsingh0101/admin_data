class AdminData::MainController  < AdminData::BaseController 

  unloadable

  before_filter :ensure_is_allowed_to_update, 
                :only => [:destroy, :delete, :edit, :update, :create]

  before_filter :get_class_from_params,
                :only => [ :table_structure, :list,:show,:destroy,:delete,
                           :edit,:new,:update, :create]

  before_filter :get_model_and_verify_it, :only => [:destroy, :delete, :edit, :update, :show]
  
  def table_structure
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
  end

  def index
    render
  end

  def list
    if params[:base]
      model= Object.const_get(params[:base]).find(params[:model_id])
      has_many_proxy = model.send(params[:send].intern)
      @records = has_many_proxy.send(  :paginate,
                                       :page => params[:page],
                                       :per_page => per_page,
                                       :order => "#{@klass.table_name}.id desc")
    else
      @records = @klass.paginate( :page => params[:page],
                                  :per_page => per_page,
                                  :order => "#{@klass.table_name}.id desc")
    end
  end

  def show
    render
  end

  def destroy
    @klass.send(:destroy, params[:model_id])
    flash[:success] = 'Record was destroyed'
    redirect_to admin_data_list_path(:klass => @klass.name)
  end

  def delete
    @klass.send(:delete, params[:model_id])
    flash[:success] = 'Record was deleted'
    redirect_to admin_data_list_path(:klass => @klass.name)
  end

  def edit
    render
  end

  def new
    @model = @klass.send(:new)
  end

  def update
    model_name_underscored = @klass.to_s.underscore

    model_attrs = params[model_name_underscored]

    if @model.update_attributes(model_attrs)
      flash[:success] = "Record was updated"
      redirect_to admin_data_show_path(:model_id => @model.id, :klass => @klass.to_s)
    else
      render :action => 'edit'
    end
  end

  def create
    model_name_underscored = @klass.to_s.underscore
    model_attrs = params[model_name_underscored]
    @model = @klass.create(model_attrs)
    if @model.errors.any?
      render :action => 'new'
    else
      flash[:success] = "Record was created"
      redirect_to admin_data_show_path(:model_id => @model.id, :klass => @klass.name)
    end
  end

  private

  def table_name_and_attribute_name(klass,column)
    table_name_and_attribute_name =  klass.table_name+'.'+column.name
  end

  def get_model_and_verify_it
    @model = @klass.send(:find_by_id,params[:model_id])
    if @model.blank?
      render :text => "<h2>#{@klass.name} not found: #{params[:model_id]}</h2>", :status => 404 
    end
  end

end
