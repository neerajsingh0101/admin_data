module AdminData
  class TableStructureController < ApplicationController

    before_filter :get_class_from_params

    def index
      @page_title = 'table_structure'
      @indexes = []
      if (indexes = ActiveRecord::Base.connection.indexes(@klass.table_name)).any?
        add_index_statements = indexes.map do |index|
          statment_parts = [ ('add_index ' + index.table.inspect) ]
          statment_parts << index.columns.inspect
          statment_parts << (':name => ' + index.name.inspect)
          statment_parts << ':unique => true' if index.unique

          '  ' + statment_parts.join(', ')
        end
        add_index_statements.sort.each { |index| @indexes << index }
      end
      respond_to {|format| format.html}
    end

  end
end

