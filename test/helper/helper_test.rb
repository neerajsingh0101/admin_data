require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class HelperTest < ActionView::TestCase

  self.helper_class = AdminData::Helpers

  def test_admin_data_get_value_for_column
    column = Article.columns.select {|column| column.name.to_s == 'title'}.first
    @article = Factory(:article)
    output = admin_data_get_value_for_column(column,@article,{})
    assert_equal 'this is a dummy title', output
  end

  def test_admin_data_get_value_for_column_using_truncate_method
    column = Article.columns.select {|column| column.name.to_s == 'title'}.first
    @article = Factory(:article, :title => 'this is a very very very long long long title')
    options = {}

    output = admin_data_get_value_for_column(column,@article,{:limit => 15})
    assert_equal 'this is a ve...', output
  end

end
