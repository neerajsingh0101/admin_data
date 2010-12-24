module AdminData

  class CrudController  < ApplicationController

    before_filter :get_class_from_params, :only => [:show, :destroy, :del, :edit, :new, :update, :create]

    before_filter :get_model_and_verify_it, :only => [:destroy, :del, :edit, :update, :show]

    before_filter :ensure_is_allowed_to_update, :only => [:destroy, :del, :edit, :update, :create]

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
      model_attrs = params[@klass.name.underscore]
      @columns = columns_list

      respond_to do |format|
        if @model.update_attributes(model_attrs)
          format.html do
            flash[:success] = "Record was updated"
            redirect_to admin_data_path(:id => @model, :klass => @klass.name.underscore)
          end
          format.js { render :json => {:success => true}}
        else
          format.html { render :action => 'edit' }
          format.js { render :json => {:error => @model.errors.full_messages.join } }
        end
      end
    end

    def create
      model_attrs = params[@klass.name.underscore]
      @model = @klass.create(model_attrs)
      @columns = columns_list

      respond_to do |format|
        if @model.errors.any?
          format.html { render :action => 'new' }
          format.js { render :json => {:error => @model.errors.full_messages.join() }}
        else
          format.html do
            flash[:success] = "Record was created"
            redirect_to admin_data_path(:id => @model, :klass => @klass.name.underscore)
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

      _proc = AdminData.config.find_conditions[@klass.name]
      if _proc && (find_conditions = _proc.call(params)) && find_conditions.has_key?(:conditions)
        condition = find_conditions.fetch(:conditions)
      end

      unless @model = @klass.find(:first, :conditions => condition)
        render :text => "#{@klass.name} not found: #{params[:id]}"
        return
      end
    end

    def columns_list
      params[:attr].blank? ? @klass.columns : @klass.columns.find_all {|col| params[:attr] == col.name}
    end

  end
end
