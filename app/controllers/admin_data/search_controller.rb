require File.join(AdminData::LIBPATH, 'admin_data', 'search')

class SearchAction
  attr_accessor :relation, :success_message

  def initialize(relation)
    @relation = relation
  end

  def delete
    count = relation.count
    relation.delete_all
    self.success_message = "#{count} #{AdminData::Util.pluralize(count, 'record')} deleted"
  end

  def destroy
    count = relation.count
    relation.find_in_batches do |group|
      group.each {|record| record.destroy }
    end
    self.success_message = "#{count} #{AdminData::Util.pluralize(count, 'record')} destroyed"
  end
end

module AdminData
  class SearchController < ApplicationController

    layout 'search'

    include Search

    before_filter :get_class_from_params
    before_filter :ensure_valid_children_klass, :only => [:quick_search]
    before_filter :ensure_is_authorized_for_update_opration, :only => [:advance_search]
    before_filter :set_column_type_info, :only => [:advance_search]


    def quick_search
      @page_title = "Search #{@klass.name.underscore}"
      order = default_order

      if params[:base]
        klass = Util.camelize_constantize(params[:base])
        model = klass.find(params[:model_id])
        has_many_proxy = model.send(params[:children].intern)
        @total_num_of_children = has_many_proxy.send(:count)
        h = { :page => params[:page], :per_page => per_page, :order => order }
        @records = has_many_proxy.send(:paginate, h)
      else
        params[:query] = params[:query].strip unless params[:query].blank?
        cond = build_quick_search_conditions(@klass, params[:query])
        h = { :page => params[:page], :per_page => per_page, :order => order, :conditions => cond }
        @records = @klass.unscoped.paginate(h)
      end
      respond_to {|format| format.html}
    end


    def advance_search
      @page_title = "Advance search #{@klass.name.underscore}"
      hash = build_advance_search_conditions(@klass, params[:adv_search])
      relation = hash[:cond]
      errors = hash[:errors]
      order = default_order

      respond_to do |format|
        format.html { render }
        format.js {

          unless hash[:errors].blank?
            file = File.join(AdminData::LIBPATH, '..', 'app','views', 'admin_data', 'search', 'search', '_errors.html.erb')
            render :file =>  file, :locals => {:errors => errors}
            return
          end

          search_action = SearchAction.new(relation)

          case params[:admin_data_advance_search_action_type]
          when 'destroy'
            search_action.destroy
          when 'delete'
            search_action.delete
          else
            @records = relation.order(order).paginate(:page => params[:page], :per_page => per_page)
          end

          if search_action.success_message
            render :json => {:success => search_action.success_message }
          else
            file = "/admin_data/search/search/listing.html.erb"
            render :partial => file, :locals => {:klass => @klass}, :layout => false
          end
        }
      end
    end

    private

    def ensure_valid_children_klass
      if params[:base]
        begin
          model_klass = Util.camelize_constantize(params[:base])
        rescue NameError => e #incase params[:base] is junk value
          render :text => "#{params[:base]} is an invalid value", :status => :not_found
          return
        end

        ar_util = ActiveRecordUtil.new(model_klass)
        if ar_util.declared_has_many_association_names.include?(params[:children]) || ar_util.declared_habtm_association_names.include?(params[:children])
          #proceed
        else
          render :text => "#{params[:children]} is not a valid has_many association", :status => :not_found
          return
        end
      end
    end

    def ensure_is_authorized_for_update_opration
      if %w(destroy delete).include? params[:admin_data_advance_search_action_type]
        render :text => 'not authorized' unless is_allowed_to_update?
      end
    end

    def default_order
      params[:sortby] || "#{@klass.send(:table_name)}.#{@klass.send(:primary_key)} desc"
    end

    def set_column_type_info
      column_type_info = @klass.columns.collect { |column|
        #JSLint complains if a hash has key named boolean. So I am changing the key to booleant
        column_type =  (column.type.to_s == 'boolean') ? 'booleant' : column.type.to_s
        %Q{ "#{column.name}":"#{column_type}" }
      }.join(',')
      @column_type_info = "{#{column_type_info}}"
    end

  end
end
