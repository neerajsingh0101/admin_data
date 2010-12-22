module AdminData

  class Configuration

    # Number of recores displayed while listing records
    attr_accessor :number_of_records_per_page

    # Default value is false .
    # Set this value to true if you want admin_data to ignored
    # the column_limit returned by ActiveRecord .
    attr_accessor :ignore_column_limit

    # By default this value is true .
    # Set this value to false if you do not want all the belongs_to
    # ids to be populated. If set to false then instead of a dropdown
    # user will get a text field where the id can be entered. It matters
    # only while editing or creating a new record.
    attr_accessor :drop_down_for_associations

    # Holds a proc which should be called. If the returned value is
    # true then user is granted the access. Otherwise access is denied.
    attr_writer :is_allowed_to_view

    # Holds a proc which should be called. If the returned value is
    # true then user is granted the access. Otherwise access is denied.
    attr_writer :is_allowed_to_update

    # Holds a proc which should be called. If the returned value is
    # true then user is granted the access. Otherwise access is denied.
    attr_writer :is_allowed_to_view_feed

    # For feed authentication a combination of user_id and password is used.
    # This attribute sets the user_id .
    attr_accessor :feed_authentication_user_id

    # For feed authentication a combination of user_id and password is used.
    # This attribute sets the password .
    attr_accessor :feed_authentication_password

    # Tell AdminData to not to use id for models like given below.
    #
    # class City < ActiveRecord::Base
    #   def to_param
    #     self.permanent_name
    #   end
    # end
    #
    #  AdminData.config do |config|
    #    proc = lambda {|params| {:conditions => ["permanent_name = ?", params[:id] ] } }
    #    config.find_conditions = {'City' => proc }
    #  end
    #
    attr_accessor :find_conditions

    # Tell AdminData how to display the value for a column
    #
    #  AdminData.config do |config|
    #    proc = lambda {|model| model.send(:data).inspect}
    #    config.column_settings = {'City' => {:data => proc } }
    #  end
    #
    attr_accessor :column_settings

    # Tell AdminData how to order the columns for a model.
    #
    #  AdminData.config do |config|
    #    config.column_order = {'City' => [:id, :title, :body, :published_at, :author_name]}
    #  end
    #
    attr_accessor :columns_order

    def is_allowed_to_view
      return lambda {|controller| return true } if Rails.env.development?
      @is_allowed_to_view || lambda {|_| nil }
    end

    def is_allowed_to_update
      return lambda {|controller| return true } if Rails.env.development?
      @is_allowed_to_update || lambda {|_| nil }
    end

    def is_allowed_to_view_feed
      return lambda {|controller| return true } if Rails.env.development?
      @is_allowed_to_view_feed || lambda {|_| nil }
    end

    # TODO explain why it is needed
    attr_reader :adapter_name

    # Tell AdminData how to name a column in a listing
    # Example:
    #
    # config.column_headers = {'Timesheet' => {:id => 'ID'}
    #
    attr_accessor :column_headers

    def initialize
      @number_of_records_per_page =  50
      @is_allowed_to_view         = nil
      @is_allowed_to_update       = nil
      @is_allowed_to_view_feed    = nil
      @find_conditions            = {}
      @drop_down_for_associations = true
      @columns_order              = {}
      @column_headers             = {}
      @column_settings            = {}
      @adapter_name               =  ActiveRecord::Base.connection.adapter_name
      @ignore_column_limit        = false
    end
   
    def display_assoc?( class_name )
      case @drop_down_for_associations
        when Hash
          return @drop_down_for_associations[ class_name ]
        when TrueClass, FalseClass
          return @drop_down_for_associations
        when NilClass 
          return false
        else
          raise "Configuration Error. #{@drop_down_for_associations} " \
                "must be true, false or a Hash."
      end
    end 

  end

end
