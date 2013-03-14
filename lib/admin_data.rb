require 'will_paginate'

require 'admin_data/engine'

module AdminData
  extend ActiveSupport::Autoload

  class NoCreatedAtColumnException < Exception 

  end

  LIBPATH = File.dirname(__FILE__)

  autoload :Configuration
  autoload :Util
  autoload :Config
  autoload :ActiveRecordUtil
  autoload :SetupConfig
  autoload :DateUtil
  autoload :Search
  autoload :Analytics
  autoload :ModelFinder

  include SetupConfig
end
