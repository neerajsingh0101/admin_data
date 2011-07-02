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

    class Row
      attr_accessor :klass, :relationship, :with_type, :operator_value, :operator

      def initialize(input)
        @klass = input[:klass]
        @relationship = input[:relationship]
        @with_type = input[:with_type]
        @operator_value = input[:operator_value]
        @operator = input[:operator]
      end

      def relationship_type(all_associations_hash)
        all_associations_hash[relationship]
      end

      def operator_value
        @operator_value.blank? ? 0 : @operator_value
      end

      def operator
        @operator.blank? ? '>' : @operator.gsub(/count/,'').strip
      end

      def title(associated_klass)
        if with_type == 'without'
          "#{klass.pluralize} without #{associated_klass.name.underscore}".html_safe
        else
          s = "#{klass.pluralize} with #{associated_klass.name.underscore}"
          s << " count #{operator} #{operator_value}" unless (operator == '>' && operator_value == 0)
          return s.html_safe
        end
      end

    end

    def pie_record(row)
      row = Row.new(row)
      record = OpenStruct.new
      klass = row.klass.camelize.constantize

      set_association_info(klass)

      aru = ActiveRecordUtil.new(klass)

      case row.relationship_type(@all_associations_hash)
      when 'has_many'
        associated_klass = aru.klass_for_association_type_and_name(:has_many, row.relationship)
        hm_instance = Analytics::HasManyAssociation.new(klass, associated_klass, row.relationship)
      when 'has_one'
        associated_klass = aru.klass_for_association_type_and_name(:has_one, row.relationship)
        hm_instance = Analytics::HasOneAssociation.new(klass, associated_klass, row.relationship)
      end

      if row.with_type == 'with'
        hash = {:count => row.operator_value, :operator => row.operator}
        record.data = hm_instance.in_count(hash)
      else
        record.data = hm_instance.not_in_count
      end
      record.title = row.title(associated_klass)
      record
    end

  end
end
