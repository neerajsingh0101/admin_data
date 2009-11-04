module Search

  class Term

    attr_accessor :error,:table_name
    attr_accessor :field,:operator,:operands

    def like_operator
      ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? 'ILIKE' : 'LIKE'
    end

    def initialize(klass,value)
      @table_name = klass.table_name
      compute_fields(value)
    end

    def compute_fields(value)
      @field,@operator,@operands = value.values_at(:col1,:col2,:col3)
      # field value is directly used in the sql statement. So it is important to sanitize it
      @field      = @field.gsub(/\W/,'')
      @operands   = (@operands.blank? ? @operands : @operands.downcase.strip)
    end

    def sql_field_name
      "#{table_name}.#{field}"
    end

    def values_after_cast
      case operator
      when /(is_on|is_on_or_before_date|is_on_or_after_date)/:
        AdminDataDateValidation.validate(operands)
      when /(is_equal_to|greater_than|less_than)/:
        operands.to_i
      else
        operands
      end
    end

    def operand_required?
      operator =~ /(contains|is_exactly|does_not_contain|is_on
                     |is_on_or_before_date|is_on_or_after_date
                     |greater_than|less_than|is_equal_to)/
    end

    def attribute_conditions
      return if valid? && operand_required? && operands.blank?
      case operator
      when 'contains':
        ["#{sql_field_name} #{like_operator} ?","%#{operands}%"]
      when 'is_exactly':
        ["#{sql_field_name} = ?",operands]
      when 'does_not_contain':
        ["#{sql_field_name} IS NULL OR #{sql_field_name} NOT #{like_operator} ?","%#{operands}%"]
      when 'is_false':
        ["#{sql_field_name} = ?",false]
      when 'is_true':
        ["#{sql_field_name} = ?",true]
      when 'is_null':
        ["#{sql_field_name} IS NULL"]
      when 'is_not_null':
        ["#{sql_field_name} IS NOT NULL"]
      when 'is_on':
        ["#{sql_field_name} >= ? AND #{sql_field_name} < ?",values_after_cast.beginning_of_day, values_after_cast.end_of_day]
      when 'is_on_or_before_date':
        ["#{sql_field_name} <= ?",values_after_cast.end_of_day]
      when 'is_on_or_after_date':
        ["#{sql_field_name} >= ?",values_after_cast.beginning_of_day]
      when 'is_equal_to':
        ["#{sql_field_name} = ?",values_after_cast]
      when 'greater_than':
        ["#{sql_field_name} > ?",values_after_cast]
      when 'less_than':
        ["#{sql_field_name} < ?",values_after_cast]
      else
        # it means user did not select anything in operator. Ignore it.
      end
    end

    def valid?
      @error = nil
      @error = validate
      @error.nil?
    end

    private

    def validate
      case operator
      when /(is_on|is_on_or_before_date|is_on_or_after_date)/:
        "#{operands} is not a valid date" unless AdminDataDateValidation.validate(operands)
      when /(is_equal_to|greater_than|less_than)/:
        unless operands.blank?
          "#{operands} is not a valid integer" unless operands =~ /^\d+$/
        end
      end
    end

  end

  def build_advance_search_conditions(klass, options = {} )
    options ||= {}
    terms         = options.collect {  |key,value| Term.new(klass,value) }
    valid_terms   = terms.select{ | t | t.valid? }
    errors        = (terms - valid_terms).collect { |t| t.error }
    conditions    = valid_terms.collect { |t| t.attribute_conditions }
    # queries are joined by AND
    cond = klass.send(:merge_conditions, *conditions)
    { :cond => cond, :errors => errors }
  end
end
