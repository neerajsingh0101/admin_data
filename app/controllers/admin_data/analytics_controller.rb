require "ostruct"

module AdminData
  class AnalyticsController < ApplicationController

    before_filter :get_class_from_params
    before_filter :set_ivars

    rescue_from AdminData::NoCreatedAtColumnException, :with => :render_no_created_at

    def build_chart
      set_association_info(@klass)
    end

    def set_association_info(klass)
      aru = ActiveRecordUtil.new(klass)
      s = []
      @all_associations_names = ['']
      
      aru.declared_habtm_association_names.each do |a| 
        s << %Q{ "#{a}":"habtm" } 
        @all_associations_names << a
      end

      aru.declared_belongs_to_association_names.each do |a| 
        s << %Q{ "#{a}":"belongs_to" } 
        @all_associations_names << a
      end

      aru.declared_has_one_association_names.each do |a| 
        s << %Q{ "#{a}":"has_one" } 
        @all_associations_names << a
      end

      aru.declared_has_many_association_names.each do |a| 
        s << %Q{ "#{a}":"has_many" } 
        @all_associations_names << a
      end

      @all_associations_json = "{#{s.join(',')}}"
    end

    def pie_record(row)
      record = OpenStruct.new
      klass = row[:klass].camelize.constantize

      set_association_info

      relationship = row[:relationship]
      hm_klass = ActiveRecordUtil.new(klass).klass_for_association_type_and_name(:has_many, relationship)
      hm_instance = Analytics::HmAssociation.new(klass, hm_klass, relationship)


      if row[:with_type] == 'with'
        record.data = hm_instance.count_of_main_klass_records_in_hm_klass
        record.title = "#{klass.name.pluralize} with #{hm_klass.name.underscore}"
      else
        record.data = hm_instance.count_of_main_klass_records_not_in_hm_klass
        record.title = "#{klass.name.pluralize} without #{hm_klass.name.underscore}"
      end
      record
    end

    def build_chart_search
      @data_points = []

      params[:search].each do |key, value|
        @data_points << pie_record(value)
      end

      respond_to do |format|
        format.js do
          render :template => 'admin_data/analytics/build_chart_search', :layout => false
        end
      end
    end


    def render_no_created_at
      render :text => "Model #{@klass} does not have created_at column"
    end

    def daily
      @chart_title = "#{@klass.name} records created in the last 30 days"

      a = AdminData::Analytics::Trend.daily_report(@klass, Time.now)
      @chart_data_s = a.map {|e| e.last }.join(', ')
      @chart_data_x_axis = a.map {|e| e.first}.join(', ')
      render :action => 'index'
    end

    def monthly
      @chart_title = "#{@klass.name} rercords created last year"
      a = AdminData::Analytics::Trend.monthly_report(@klass, Time.now)
      @chart_data_s = a.map {|e| e.last }.join(', ')
      @chart_data_x_axis = a.map {|e| e.first}.join(', ')
      render :action => 'index'
    end

    def set_ivars
      @chart_width = 950
      @chart_height = 400
      @chart_h_axis_title = ''
      @chart_legend_name = 'Created'
    end

  end
end
