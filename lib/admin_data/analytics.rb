require "active_support/all"

module AdminData
  module Analytics

    # a utility class to handle date interpolation for different databases
    class Dater
      attr_accessor :adapter, :type

      def initialize(adapter, type = 'daily')
        @adapter = adapter
        @type = type
      end

      def date_select_key
        "date_data"
      end

      def group_by_key
        if adapter =~ /postgresql/i
          self.type == 'monthly' ? "date_part('year', created_at), date_part('month', created_at)" : "date_data"
        elsif adapter =~ /mysql/i
          self.type == 'monthly' ? "YEAR(created_at), MONTH(created_at)" : "date_data"
        else
          self.type == 'monthly' ? "strftime('%Y', created_at), strftime('%m', created_at)" : "date_data"
        end
      end

      def count_select_key
        "count_data"
      end

      def count_function
        "count(*) as count_data"
      end

      def date_select_function
        self.type == 'monthly' ? date_select_function_monthly : date_select_function_daily
      end

      private

      def date_select_function_monthly
        if adapter =~ /mysql/i
          "MONTH(created_at) as date_data"
        elsif adapter =~ /postgresql/i
          "date_part('month', created_at) as date_data"
        else
          "strftime('%m', created_at) as date_data"
        end
      end

      def date_select_function_daily
        if adapter =~ /mysql/i
          "date_format(created_at, '%Y-%m-%d') as date_data"
        else
          "date(created_at) as date_data"
        end
      end

    end

    def self.monthly_report(klass, end_date)
      begin_date = end_date.ago(1.year)
      raise "begin_date should not be after end_date" if begin_date > end_date
      raise AdminData::NoCreatedAtColumnException unless klass.columns.find {|r| r.name == 'created_at'}

      begin_date = begin_date.beginning_of_day
      end_date = end_date.end_of_day

      dater = Dater.new(ActiveRecord::Base.connection.adapter_name, 'monthly')

      query = klass.unscoped
      query = query.where(["created_at >= ?", begin_date])
      query = query.where(["created_at <= ?", end_date])
      query = query.group(dater.group_by_key)
      query = query.select(dater.date_select_function)
      query = query.select(dater.count_function)
      debug "sql: " + query.to_sql
      result = query.all
      debug "sql result: #{result.inspect}"

      extract_data_from_result_set_monthly(result, dater, begin_date, end_date)
    end

    def self.extract_data_from_result_set_monthly(result, dater, begin_date, end_date)
      debug "extracting from result set now"
      result_hash = {}
      result.each do |record|
        result_hash.merge!(record[dater.date_select_key].to_i => record[dater.count_select_key])
      end

      debug "result_hash.inspect is #{result_hash.inspect}"
      
      current_month = begin_date.strftime('%m').to_i
      months_order = (1..current_month).to_a.reverse + (current_month..12).to_a.reverse
      months_order.uniq!.reverse!

      debug "months order is #{months_order.inspect}"

      final_hash = ActiveSupport::OrderedHash.new
      months_order.each do |month|
        month = month.to_i #sqlite3 has months as 03 instead of 3
        m = Time.now.change(:month => month)
        m = m.ago(1.year) if month > current_month

        key = m.strftime('%b-%Y')
        key = "'#{key}'"
        if dater.adapter =~ /postgresql/i
          value = result_hash[month]
        elsif dater.adapter =~ /mysql/i
          value = result_hash[month]
        else
          value = result_hash[month]
        end
        value = value.to_i
        debug "month: #{month} key: #{key} value: #{value}"
        final_hash.merge!(key => value)
      end

      final_hash.to_a.tap {|e| debug e.inspect }
    end
      
    def self.daily_report(klass, end_date)
      begin_date = end_date.ago(1.month)
      raise "begin_date should not be after end_date" if begin_date > end_date
      raise AdminData::NoCreatedAtColumnException unless klass.columns.find {|r| r.name == 'created_at'}

      begin_date = begin_date.beginning_of_day
      end_date = end_date.end_of_day

      dater = Dater.new(ActiveRecord::Base.connection.adapter_name)

      query = klass.unscoped
      query = query.where(["created_at >= ?", begin_date])
      query = query.where(["created_at <= ?", end_date])
      query = query.group(dater.group_by_key)
      query = query.select(dater.date_select_function)
      query = query.select(dater.count_function)
      debug "sql: " + query.to_sql
      result = query.all
      debug "sql result: #{result.inspect}"

      extract_data_from_result_set_daily(result, dater, begin_date, end_date).tap {|e| debug "formatted output: "+e.inspect}
    end

    def self.extract_data_from_result_set_daily(result, dater, begin_date, end_date)
      count = result.map {|r| r[dater.count_select_key] }
      dates = result.map {|r| r[dater.date_select_key] }

      debug "count is: #{count.inspect}"
      debug "dates is: #{dates.inspect}"

      final_output= []

      while(begin_date) do
        s = begin_date.strftime('%Y-%m-%d')
        final_count = if index = dates.index(s)
          count[index].to_i
        else
          0
        end
        final_output << ["'#{s}'", final_count]
        begin_date = begin_date.tomorrow
        break if begin_date > end_date
      end
      final_output
    end

    def self.debug(msg)
      #puts msg
    end

  end

end
