require 'date'

module AdminData
  class DateUtil

    # returns a time object for the given input.
    # validation is not done. It is assumed that client
    # has done validation using .valid? method.
    def self.valid?(input)
      !!parse(input)
    end

    # Usage:
    #
    # parase('13-feb-2008')     # => time object
    # parse('13-February-2008') # => time object
    # parse('13-February-2008') # => time object
    # parse('99-Feb-2008')      #=> false
    #
    def self.parse(input)
      return false if input.blank?

      input.strip!

      # remove all the white space characters
      input.gsub!(/\s/,'')

      return false if input.length < 9

      dd,mm,yyyy = input.split('-')
      return false if dd.nil? || mm.nil? || yyyy.nil?

      # month must be of atleast three characters
      return false if mm.length < 3

      mm = mm.downcase[0,3]

      months = {'jan' => 1, 'feb' => 2, 'mar' => 3, 'apr' => 4, 'may' => 5, 'jun' => 6,
                'jul' => 7, 'aug' => 8, 'sep' => 9, 'oct' => 10, 'nov' => 11, 'dec' => 12 }

      return false unless months.keys.include? mm

      mm = months[mm].to_i
      yyyy = yyyy.to_i
      dd = dd.to_i

      # validate date values
      begin
        Date.new(yyyy,mm,dd)
      rescue
        return false
      end

      Time.now.change(:year => yyyy, :month => mm, :day => dd, :hour => 0)
    end

  end
end
