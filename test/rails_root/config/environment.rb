old_verbose, $VERBOSE = $VERBOSE, nil
RAILS_GEM_VERSION = '= 2.3.5' unless defined? RAILS_GEM_VERSION
$VERBOSE = old_verbose

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.log_level = :debug
  config.cache_classes = false
  config.whiny_nils = true
  config.action_controller.session = {
    :key    => 'admin_data_test_session',
    :secret => 'ceae6058a816b1446e09ce90d8372511'
  }
end


