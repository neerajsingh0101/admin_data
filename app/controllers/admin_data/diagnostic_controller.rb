class AdminData::DiagnosticController  < AdminData::BaseController 

   unloadable

   def index
      render
   end

   def missing_index
      @indexes = {}
      conn = ActiveRecord::Base.connection
      conn.tables.each do |table|
        indexed_columns = conn.indexes(table).map { |i| i.columns }.flatten
        conn.columns(table).each do |column|
          if column.name.match(/_id/) && !indexed_columns.include?(column.name)
            @indexes[table] ||= []
            @indexes[table] << column.name
          end
        end
      end
   end

end
