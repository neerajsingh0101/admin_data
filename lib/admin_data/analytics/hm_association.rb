require "active_support/all"

module AdminData
  module Analytics
    class HmAssociation

      attr_accessor :main_klass, :hm_klass, :hm_relationship_name

      def initialize(main_klass, hm_klass, hm_relationship_name)
        @main_klass = main_klass
        @hm_klass = hm_klass
        @hm_relationship_name = hm_relationship_name.intern
      end

      def count_of_main_klass_records_not_in_hm_klass
        foreign_key = AdminData::ActiveRecordUtil.foreign_key_for_has_many(main_klass, hm_relationship_name) 

        sql  = %Q{
          
          select count(*) as count_data
          from #{main_klass.table_name}
          where #{main_klass.table_name}.id NOT IN (
            select #{hm_klass.table_name}.#{foreign_key}
            from #{hm_klass.table_name}
          )
        
        }
        record = main_klass.find_by_sql(sql).first
        record['count_data'].to_i
      end

      def count_of_main_klass_records_in_hm_klass(count = nil)
        foreign_key = AdminData::ActiveRecordUtil.foreign_key_for_has_many(main_klass, hm_relationship_name) 

        having_sql = if count
          "having count(#{hm_klass.table_name}.id) = #{count}"
        else
          "having count(#{hm_klass.table_name}.id) > 0"
        end

        sql = %Q{
        
          select #{main_klass.table_name}.id, count(#{hm_klass.table_name}.id)
          from #{main_klass.table_name} join #{hm_klass.table_name} on #{main_klass.table_name}.id = #{hm_klass.table_name}.#{foreign_key}
          group by #{main_klass.table_name}.id
          #{having_sql}
        }

        main_klass.find_by_sql(sql).size
      end

    end
  end
end
