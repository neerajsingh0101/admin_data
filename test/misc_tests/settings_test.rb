require 'test/test_helper'

class AdminData::AdminDataConfigTest < ActionController::TestCase
  context 'setting configuration parameters' do
    teardown do
      AdminDataConfig.initialize_defaults
    end

    %w(find_conditions     plugin_dir            will_paginate_per_page 
       view_security_check update_security_check use_admin_data_layout ).each do |valid_key|
      should "store #{valid_key} setting" do
        AdminDataConfig.set = { valid_key.to_sym => "some value for #{valid_key}" }
        assert_equal "some value for #{valid_key}", AdminDataConfig.setting[valid_key.to_sym]
      end
    end

    context "get an error with a bad key" do
      should "raise error when attempting to set bad key" do
        assert_raises(RuntimeError) { AdminDataConfig.set = { :a_bad_key => "some value" }}
      end
    end

  end
end