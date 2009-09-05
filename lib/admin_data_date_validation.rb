require 'date'

class AdminDataDateValidation
  
  def self.validate_with_operator(input)
    return false if input.blank?
    
    input.strip!
    
    # replace multiple consecutive white spaces by one single whitespace
    input.gsub!(/\s+/,' ')
    operator, date = input.split
    return false if operator.nil?
    return false unless %w(> < >= <= =).include? operator
    validate(date)
  end
  

  # Usage:
  #
  # validate('13-feb-2008') # => time_object
  # validate('13-February-2008') # => time_object
  # validate('13-February-2008') # => time_object
  # validate('30-Feb-2008') #=> false
  #
  def self.validate(input)
    return false if input.nil?
    
    input.strip!
    
    # remove all the white space characters
    input.gsub!(/\s/,'')
    
    return false if input.length < 9
    
    dd,mm,yyyy = input.split('-')
    return false if dd.nil?
    return false if mm.nil?
    return false if yyyy.nil?
    
    # month must be of aleast three characters
    return false if mm.length < 3
    
    mm = mm.downcase
    
    #get only the first three characters
    mm = mm[0,3]
    
    months = {'jan' => 1,
              'feb' => 2,
              'mar' => 3,
              'apr' => 4,
              'may' => 5,
              'jun' => 6,
              'jul' => 7,
              'aug' => 8,
              'sep' => 9,
              'oct' => 10,
              'nov' => 11,
              'dec' => 12 }
              
    return false unless months.keys.include? mm
    
    mm = months[mm]
    
    
    mm = mm.to_i
    yyyy = yyyy.to_i
    dd = dd.to_i
    
    # validate date values
    begin
      # puts "yyyy is #{yyyy}"
      # puts "mm is #{mm}"
      # puts "dd is #{dd}"
      
      Date.new(yyyy,mm,dd)
    rescue  => e
      return false
    end
    
    t = Time.now
    t.change(:year => yyyy, :month => mm, :day => dd, :hour => 0)
  end
  
  
end
