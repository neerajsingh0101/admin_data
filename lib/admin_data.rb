require 'admin_data/rails_version_check'
require 'will_paginate'

module AdminData
  extend ActiveSupport::Autoload

  LIBPATH = ::File.dirname(__FILE__)

  autoload :Configuration
  autoload :Util, 'admin_data/util'
  autoload :Config, 'admin_data/config' #deprecated message
  autoload :ActiveRecordUtil, 'admin_data/active_record_util'

  class << self
    # A configuration object that acts like a hash.
    # See AdminData::Configuration for details.
    attr_accessor :configuration

    # Call this method to modify defaults in initializer.
    #
    # @example
    #   AdminData.config do |config|
    #     config.number_of_records_per_page = 20
    #   end
    def config
      self.configuration ||= Configuration.new
      block_given? ? yield(self.configuration) : self.configuration
    end
  end

end

if Rails.version >= '3.0'
  require 'admin_data/railtie'
else
  raise "Please see documentation at http://github.com/neerajdotname/admin_data/wiki to find out how to use this gem with rails 2.3.x"
end

# move date_validation to inside admin_data
require 'admin_data_date_validation'
