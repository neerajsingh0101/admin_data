require 'test/test_helper'

class AdminData::AdminDataConfigTest < ActionController::TestCase
  context 'setting configuration parameters' do
    teardown do
      AdminData::Config.initialize_defaults
    end

    %w(
    find_conditions
    plugin_dir
    will_paginate_per_page
    is_allowed_to_view
    is_allowed_to_update
    ).each do |valid_key|
      should "store #{valid_key} setting" do
        AdminData::Config.set = { valid_key.to_sym => "some value for #{valid_key}" }
        assert_equal "some value for #{valid_key}", AdminData::Config.setting[valid_key.to_sym]
      end
    end

    context "get an error with a bad key" do
      should "raise error when attempting to set bad key" do
        assert_raises(RuntimeError) { AdminData::Config.set = { :a_bad_key => "some value" }}
      end
    end

  end
end
