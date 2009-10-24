require 'test/test_helper'

class HelperTest < ActionView::TestCase

  include FlexMock::TestCase

  self.helper_class = AdminData::Helpers

  def setup
    @f = flexmock
  end

  def test_admin_data_form_field_id
    @article = Factory(:article)
    col = Article.columns.detect {|col| col.name == 'article_id'}
    output = admin_data_form_field(Article, @article, col, @f)
    assert_equal "(auto)", output
  end

  def test_admin_data_form_field_comment_id
    @comment = Factory(:comment)
    col = Comment.columns.detect {|col| col.name == 'id'}
    output = admin_data_form_field(Comment, @comment, col, @f)
    assert_equal "(auto)", output
  end


  def test_admin_data_form_field_hits_count
    @article = Factory(:article)
    col = Article.columns.detect {|col| col.name == 'hits_count'}
    expected = '<input> for hits_count'
    @f.should_receive(:text_field).with('hits_count', {:class => "nice-field", :size => 56}).and_return(expected)
    output = admin_data_form_field(Article, @article, col, @f)
    assert_equal [expected], output
  end

  def test_admin_data_form_field_title
    @article = Factory(:article)
    col = Article.columns.detect {|col| col.name == 'title'}
    expected = '<input> for hits_count'
    @f.should_receive(:text_field).with('title', {:class => "nice-field", :size => 56, :maxlength => 255}).and_return(expected)
    output = admin_data_form_field(Article, @article, col, @f)
    assert_equal [expected], output
  end

  def test_admin_data_form_field_published_at
    @article = Factory(:article, :published_at => Time.parse('Aug 31, 1999'))
    col = Article.columns.detect {|col| col.name == 'published_at'}
    expected_year_input = '<input> for year'
    expected_dropdowns  = '<select> for month and <select> for day'
    flexmock(self).should_receive(:params).and_return({:action => 'edit'})
    flexmock(self).should_receive(:text_field_tag).with('article[published_at(1i)]', 1999, :class => 'nice-field').and_return(expected_year_input)
    @f.should_receive(:datetime_select).with('published_at', {:discard_year => true}).and_return(expected_dropdowns)
    output = admin_data_form_field(Article, @article, col, @f)
    assert_equal [expected_year_input, expected_dropdowns], output
  end

  def test_admin_data_form_field_published_at_uses_current_date_for_new
    @article = Factory(:article, :published_at => Time.parse('Aug 31, 1999'))
    col = Article.columns.detect {|col| col.name == 'published_at'}
    expected_year_input = '<input> for year'
    expected_dropdowns  = '<select> for month and <select> for day'
    flexmock(self).should_receive(:params).and_return({:action => 'new'})
    flexmock(self).should_receive(:text_field_tag).with('article[published_at(1i)]', Time.now.year, :class => 'nice-field').and_return(expected_year_input)
    @f.should_receive(:datetime_select).with('published_at', {:discard_year => true}).and_return(expected_dropdowns)
    output = admin_data_form_field(Article, @article, col, @f)
    assert_equal [expected_year_input, expected_dropdowns], output
  end

  def test_admin_data_form_field_foreign_key_article_id
    @article = Factory(:article)
    @comment = Factory(:comment, :article => @article)
    col = Comment.columns.detect {|col| col.name == 'article_id'}
    expected  = '<select> for articles'
    all_articles = flexmock
    flexmock(Article).should_receive(:all).with(:order => "article_id asc").and_return(all_articles)
    @f.should_receive(:collection_select).with('article_id', all_articles, :id, 'article_id', {:include_blank => true} ).and_return(expected)
    output = admin_data_form_field(Comment, @comment, col, @f)
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
