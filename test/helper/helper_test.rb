require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class HelperTest < ActionView::TestCase

  include FlexMock::TestCase

  self.helper_class = AdminData::Helpers

  def test_admin_data_form_field_id
    @article = Factory(:article)
    col = Article.columns.detect {|col| col.name == 'article_id'}
    output = admin_data_form_field(Article, @article, col)
    assert_equal "(auto)", output
  end

  def test_admin_data_form_field_comment_id
    @comment = Factory(:comment)
    col = Comment.columns.detect {|col| col.name == 'id'}
    output = admin_data_form_field(Comment, @comment, col)
    assert_equal "(auto)", output
  end


  def test_admin_data_form_field_hits_count
    @article = Factory(:article)
    col = Article.columns.detect {|col| col.name == 'hits_count'}
    output = admin_data_form_field(Article, @article, col)
    expected = %{<input class="nice-field" id="article_hits_count" name="article[hits_count]" size="56" type="text" value="1" />}
    assert_equal [expected], output
  end

  def test_admin_data_form_field_title
    @article = Factory(:article)
    col = Article.columns.detect {|col| col.name == 'title'}
    output = admin_data_form_field(Article, @article, col)
    expected = %{<input class="nice-field" id="article_title" maxlength="255" name="article[title]" size="56" type="text" value="this is a dummy title" />}
    assert_equal [expected], output
  end

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

  def test_admin_data_get_value_for_column_for_integer
    @article = Factory(:article, :hits_count => 100)
    column = Article.columns.select {|column| column.name.to_s == 'hits_count'}.first
    output = admin_data_get_value_for_column(column, @article)
    assert_equal 100, output
  end

  def test_admin_data_get_value_for_column_for_integer2
    @article = Factory(:article, :hits_count => 100)
    column = Article.columns.select {|column| column.name.to_s == 'hits_count'}.first
    output = admin_data_get_value_for_column(column, @article, {:limit => 10})
    assert_equal 100, output
  end


  def test_admin_data_get_value_for_column_using_truncate_method_with_exception
    column = Article.columns.select {|column| column.name.to_s == 'title'}.first
    @article = Factory(:article, :title => 'this is a very very very long long long title')
    options = {}

    #truncate method should raise exception
    flexmock(self).should_receive('truncate').with('any_args').and_raise(Exception)

    output = admin_data_get_value_for_column(column,@article,{:limit => 15})
    assert_equal '<actual data is not being shown because truncate method failed.>', output
  end

end
