require 'will_paginate'
require 'admin_data/configuration'

module AdminData
  LIBPATH = File.expand_path(::File.dirname(__FILE__)) + File::SEPARATOR

  def self.plugin_dir
    File.expand_path(File.join(LIBPATH, '..')) + File::SEPARATOR
  end

  def self.public_dir
    File.expand_path(File.join(LIBPATH, '..', 'public')) + File::SEPARATOR
  end

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

require 'admin_data/deprecation'
require 'admin_data/extension'
require 'admin_data/util'
require 'admin_data/active_record_util'
