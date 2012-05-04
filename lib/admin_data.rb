require "admin_data/engine"

require 'will_paginate'

module AdminData
  extend ActiveSupport::Autoload

  LIBPATH = File.dirname(__FILE__)

  autoload :Configuration
  autoload :Util
  autoload :Config
  autoload :ActiveRecordUtil
  autoload :SetupConfig
  autoload :DateUtil
  autoload :Authenticator
  autoload :Search
  autoload :Analytics

  include SetupConfig

end

require 'admin_data/exceptions'
