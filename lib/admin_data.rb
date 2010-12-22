require 'admin_data/rails_version_check'
require 'will_paginate'

module AdminData
  extend ActiveSupport::Autoload

  LIBPATH = File.dirname(__FILE__)

  autoload :Configuration
  autoload :Util
  autoload :Config
  autoload :ActiveRecordUtil
  autoload :SetupConfig

  include SetupConfig

end

require 'admin_data/railtie'

# move date_validation to inside admin_data
require 'admin_data_date_validation'
