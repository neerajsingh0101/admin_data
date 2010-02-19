require File.join(File.dirname(__FILE__) , '..', '..', '..', 'lib', 'admin_data', 'search')

class AdminData::SearchController  < AdminData::BaseController

  include Search

  unloadable

  before_filter :get_class_from_params
  before_filter :ensure_is_allowed_to_view
  before_filter :ensure_is_allowed_to_view_model
  before_filter :ensure_valid_children_klass, :only => [:quick_search]
  before_filter :ensure_is_authorized_for_update_opration, :only => [:advance_search]
  before_filter :set_collection_of_columns, :only => [:advance_search]

  def quick_search
    @page_title = "Search #{@klass.name.underscore}"
    @order = default_order

    if params[:base]
      klass = AdminData::Util.camelize_constantize(params[:base])
      model = klass.find(params[:model_id])
      has_many_proxy = model.send(params[:children].intern)
      @total_num_of_children = has_many_proxy.send(:count)
      h = { :page => params[:page], :per_page => per_page, :order => @order }
      @records = has_many_proxy.send(:paginate, h)
    else
      params[:query] = params[:query].strip unless params[:query].blank?
      cond = build_quick_search_conditions(@klass, params[:query])
      h = { :page => params[:page], :per_page => per_page, :order => @order, :conditions => cond }
      @records = @klass.paginate(h)
    end
    respond_to {|format| format.html}
  end


  def advance_search
    @page_title = "Advance search #{@klass.name.underscore}"
    plugin_dir = AdminDataConfig.setting[:plugin_dir]
    hash = build_advance_search_conditions(@klass, params[:adv_search])
    @cond = hash[:cond]
    errors = hash[:errors]
    @order = default_order

    respond_to do |format|
      format.html { render }
      format.js {

        if !hash[:errors].blank?
          render :file =>  "#{plugin_dir}/app/views/admin_data/search/search/_errors.html.erb", :locals => {:errors => errors}
          return
        end
        if params[:admin_data_advance_search_action_type] == 'destroy'
          handle_advance_search_action_type_destroy
        elsif params[:admin_data_advance_search_action_type] == 'delete'
          handle_advance_search_action_type_delete
        else
          @records = @klass.paginate(:page => params[:page], :per_page => per_page, :order => @order, :conditions => @cond )
        end

        if @success_message
          render :json => {:success => @success_message }
        else
          render   :file =>  "#{plugin_dir}/app/views/admin_data/search/search/_listing.html.erb", 
                    :locals => {:klass => @klass, :records => @records}
        end
      }
    end
  end

  private

  def ensure_valid_children_klass
    if params[:base]
      begin
        model_klass = AdminData::Util.camelize_constantize(params[:base])
      rescue NameError => e #incase params[:base] is junk value
        render :text => "#{params[:base]} is an invalid value", :status => :not_found
        return
      end
      unless AdminData::Util.has_many_what(model_klass).include?(params[:children])
        render :text => "<h2>#{params[:children]} is not a valid has_many association</h2>",
        :status => :not_found
        return
      end
    end
  end

  def ensure_is_authorized_for_update_opration
    if %w(destroy delete).include? params[:admin_data_advance_search_action_type]
      render :text => 'not authorized', :status => :unauthorized unless admin_data_is_allowed_to_update?
    end
  end

  def handle_advance_search_action_type_delete
    count = @klass.send(:count, :conditions => @cond);
    @klass.find_in_batches( :conditions => @cond ) do |group|
      group.each {|record| @klass.send(:delete, record) }
    end
    @success_message = "#{count} #{AdminData::Util.pluralize(count, 'record')} deleted"
  end

  def handle_advance_search_action_type_destroy
    count = @klass.send(:count, :conditions => @cond);
    @klass.find_in_batches( :conditions => @cond ) do |group|
      group.each {|record| record.destroy }
    end
    @success_message = "#{count} #{AdminData::Util.pluralize(count, 'record')} destroyed"
  end

  def default_order
    params[:sortby] || "#{@klass.send(:table_name)}.#{@klass.send(:primary_key)} desc"
  end

  def set_collection_of_columns
    collection_of_colums = @klass.columns.collect { |column|
      #JSLint complains if a hash has key named boolean. So I am changing the key to booleant
      column_type =  (column.type.to_s == 'boolean') ? 'booleant' : column.type.to_s
      "#{column.name}:'#{column_type}'"
    }
    collection_of_colums = collection_of_colums.join(',')
    @collection_of_colums = "[{#{collection_of_colums}}]"
  end

end
