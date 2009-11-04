class AdminData::SearchController  < AdminData::BaseController 
   include Search

  unloadable

  before_filter :get_class_from_params
  before_filter :ensure_is_allowed_to_view
  before_filter :ensure_valid_children_klass, :only => [:search]

  def search
    @page_title = "Search #{@klass.name.underscore}"
    order = params[:sortby] || "#{@klass.send(:primary_key)} desc"

    if params[:base]
      model = params[:base].camelize.constantize.find(params[:model_id])
      has_many_proxy = model.send(params[:children].intern)
      @total_num_of_children = has_many_proxy.send(:count)
      @records = has_many_proxy.send(  :paginate,
                                       :page => params[:page],
                                       :per_page => per_page,
                                       :order => order )
    else
      params[:query] = params[:query].strip unless params[:query].blank?
      cond = build_search_conditions(@klass, params[:query])
      @records = @klass.paginate( :page => params[:page],
                                  :per_page => per_page,
                                  :order => order,
                                  :conditions => cond ) 
    end
    respond_to {|format| format.html}
  end

  def advance_search
    @page_title = "Advance search #{@klass.name.underscore}"
    hash = build_advance_search_conditions(@klass, params[:adv_search])
    cond = hash[:cond]
    @records = @klass.paginate(  :page => params[:page],
                                 :per_page => per_page,
                                 :order => params[:sortby],
                                 :conditions => cond )
    respond_to do |format|
      format.html { render }
      format.js {
        errors = hash[:errors]    
        plugin_dir = AdminDataConfig.setting[:plugin_dir]
        
        if errors.size > 0
          render :file =>  "#{plugin_dir}/app/views/admin_data/search/search/_errors.html.erb", 
                 :locals => {:errors => errors}
        else
          render :file =>  "#{plugin_dir}/app/views/admin_data/search/search/_listing.html.erb", 
                 :locals => {:klass => @klass, :records => @records}
        end
      }
    end
  end

  private

  def build_search_conditions(klass,search_term)
    return nil if search_term.blank?
    like_operator = ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? 'ILIKE' : 'LIKE'

    attribute_conditions = []
    klass.columns.each do |column|
      if %w(string text).include? column.type.to_s
        attribute_conditions << "#{table_name_and_attribute_name(klass,column)} #{like_operator} :search_term"
      end
    end

    condition = attribute_conditions.join(' or ')
    [condition, {:search_term => "%#{search_term.downcase}%"}]
  end

  def table_name_and_attribute_name(klass,column)
    table_name_and_attribute_name = klass.table_name + '.' + column.name
  end

  def ensure_valid_children_klass
    if params[:base]
      model_klass = params[:base].camelize.constantize
      unless AdminData::Util.has_many_what(model_klass).include?(params[:children])
        render :text => "<h2>#{params[:children]} is not a valid has_many association</h2>", :status => :not_found 
      end
    end
  end

  def is_integer?(input)
     input.to_i.to_s == input
  end

end
