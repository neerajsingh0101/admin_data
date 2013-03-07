require "test_helper"

class AdminData::ModelFinderTest < ActiveSupport::TestCase

  test "list all model from app" do
    expected = %w(User User::Student).sort

    assert_equal expected, AdminData::ModelFinder.models
  end

  test "namespaced models" do
    expected = %w(User::Student)
    assert_equal expected, AdminData::ModelFinder.namespaced_models(User) 
  end

end
