require "ostruct"

module AdminData
  class AnalyticsController < ApplicationController

    before_filter :get_class_from_params
    before_filter :set_ivars

    rescue_from AdminData::NoCreatedAtColumnException, :with => :render_no_created_at

    def chart_builder
      set_association_info(@klass)
    end

    def build_chart
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

    private

    def set_ivars
      @chart_width = 950
      @chart_height = 400
      @chart_h_axis_title = ''
      @chart_legend_name = 'Created'
    end

    def render_no_created_at
      render :text => "Model #{@klass} does not have created_at column"
    end

    def set_association_info(klass)
      aru = ActiveRecordUtil.new(klass)
      hash = {}
      
      aru.declared_habtm_association_names.each do |a| 
        hash.merge!(a => 'habtm')
      end

      aru.declared_belongs_to_association_names.each do |a| 
        hash.merge!(a => 'belongs_to')
      end

      aru.declared_has_one_association_names.each do |a| 
        hash.merge!(a => 'has_one')
      end

      aru.declared_has_many_association_names.each do |a| 
        hash.merge!(a => 'has_many')
      end

      s = []
      hash.each do |key, value|
        s << %Q{ "#{key}":"#{value}" } 
      end

      @all_associations_json = "{#{s.join(',')}}"
      @all_associations_names = hash.keys.unshift('')
      @all_associations_hash = hash
    end

    def pie_record(row)
      record = OpenStruct.new
      klass = row[:klass].camelize.constantize

      set_association_info(klass)

      relationship = row[:relationship]
      aru = ActiveRecordUtil.new(klass)

      case @all_associations_hash[relationship]
      when 'has_many'
        hm_klass = aru.klass_for_association_type_and_name(:has_many, relationship)
        hm_instance = Analytics::HasManyAssociation.new(klass, hm_klass, relationship)
      when 'has_one'
        hm_klass = aru.klass_for_association_type_and_name(:has_one, relationship)
        hm_instance = Analytics::HasOneAssociation.new(klass, hm_klass, relationship)
      end

      if row[:with_type] == 'with'
        count = (row[:operator_value] || 0).to_i
        record.data = hm_instance.in_count(:count => count)
        record.title = "#{klass.name.pluralize} with #{hm_klass.name.underscore}"
        record.title << " count #{count}" if count > 0
      else
        record.data = hm_instance.not_in_count
        record.title = "#{klass.name.pluralize} without #{hm_klass.name.underscore}"
      end
      record
    end

  end
end
