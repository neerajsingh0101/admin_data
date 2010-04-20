require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class ViewHelperTest < ActionView::TestCase

  include FlexMock::TestCase

  self.helper_class = AdminData::Helpers

  def setup
    @f = flexmock
  end

  context 'admin_data_form_field_id' do
    context 'for primary key article_id' do
      setup do
        article = Factory(:article)
        col = Article.columns.detect {|col| col.name == 'article_id'}
        @output = admin_data_form_field(Article, article, col, @f)
      end
      should 'have value auto for id' do
        assert_equal "(auto)", @output
      end
    end

    context 'for primary key id' do
      setup do
        comment = Factory(:comment)
        col = Comment.columns.detect {|col| col.name == 'id'}
        @output = admin_data_form_field(Comment, comment, col, @f)
      end
      should 'have value auto for id' do
        assert_equal "(auto)", @output
      end
    end

    context 'for text_field' do
      setup do
        article = Factory(:article)
        col = Article.columns.detect {|col| col.name == 'hits_count'}
        @expected = '<input> for hits_count'
        @f.should_receive(:text_field).with('hits_count', {:class => "nice-field", :size => 60}).and_return(@expected)
        @output = admin_data_form_field(Article, article, col, @f)
      end
      should 'have input text' do
        assert_equal @expected, @output
      end
    end
  end

  context 'for datetime_select' do
    setup do
      col = Article.columns_hash['published_at']
      @article = Factory(:article, :published_at => Time.parse('Aug 31, 1999 1:23:45'))
      initial_dropdowns  = '<input type="hidden">for year and <select>s for month and day and <select>s for time'
      @expected_html  = '<input type="text" size="4" class="nice-field">for year and <select>s for month and day and <select>s for time'
      flexmock(self).should_receive(:params).and_return({:action => 'edit'})
      @f.should_receive(:datetime_select).with('published_at', {:include_blank => true}).and_return(initial_dropdowns)
      @output = admin_data_form_field(Article, @article, col, @f)
    end
    should 'have expected output' do
      assert_equal @expected_html, @output
    end
  end

  context 'for date_select' do
    setup do
      col = Article.columns_hash['published_at']
      flexmock(col).should_receive(:type).and_return(:date)
      @article = Factory(:article, :published_at => Date.parse('Aug 31, 1999'))
      initial_dropdowns  = '<input type="hidden">for year and <select>s for month and day'
      @expected_html  = '<input type="text" size="4" class="nice-field">for year and <select>s for month and day'
      flexmock(self).should_receive(:params).and_return({:action => 'edit'})
      @f.should_receive(:date_select).with('published_at', {:discard_year => true, :include_blank => true}).and_return(initial_dropdowns)
      @output = admin_data_form_field(Article, @article, col, @f)
    end
    should 'have expected value' do
      assert_equal @expected_html, @output
    end
  end

  context 'for collection_select' do
    setup do
      @article = Factory(:article)
      @comment = Factory(:comment, :article => @article)
      col = Comment.columns.detect {|col| col.name == 'article_id'}
      @expected  = '<select> for articles'
      all_articles = flexmock
      flexmock(Article).should_receive(:all).with(:order => "article_id asc").and_return(all_articles)
      @f.should_receive(:collection_select).with('article_id', all_articles, :id, 'article_id', {:include_blank => true} ).and_return(@expected)
      @output = admin_data_form_field(Comment, @comment, col, @f)
    end
    should 'have expected value' do
      assert_equal @expected, @output
    end
  end

  context 'invoke admin_data_get_value_for_column'  do
    context 'for text column' do
      context 'untrucated case' do
        setup do
          column = Article.columns.select {|column| column.name.to_s == 'title'}.first
          @article = Factory(:article)
          @output = admin_data_get_value_for_column(column, @article, {})
        end
        should 'have untruncated title' do
          assert_equal 'this is a dummy title', @output
        end
      end

      context 'truncated case' do
        setup do
          column = Article.columns.select {|column| column.name.to_s == 'title'}.first
          @article = Factory(:article, :title => 'this is a very very very long long long title')
          options = {}

          @output = admin_data_get_value_for_column(column,@article,{:limit => 15})
        end
        should 'should have truncated title' do
          assert_equal 'this is a ve...', @output
        end
      end
    end

    context 'for integer column' do
      setup do
        @article = Factory(:article, :hits_count => 100)
        column = Article.columns.select {|column| column.name.to_s == 'hits_count'}.first
        @output = admin_data_get_value_for_column(column, @article)
      end
      should 'have right value' do
        assert_equal 100, @output
      end
    end

    context 'for integer column with truncate option should not cause any problem' do
      setup do
        @article = Factory(:article, :hits_count => 100)
        column = Article.columns.select {|column| column.name.to_s == 'hits_count'}.first
        @output = admin_data_get_value_for_column(column, @article, {:limit => 10})
      end
      should 'have right value' do
        assert_equal 100, @output
      end
    end

    context 'for text column which should raise exception' do
      setup do
        column = Article.columns.select {|column| column.name.to_s == 'title'}.first
        @article = Factory(:article, :title => 'this is a very very very long long long title')
        options = {}

        #truncate method should raise exception
        flexmock(self).should_receive('truncate').with('any_args').and_raise(Exception)

        @output = admin_data_get_value_for_column(column,@article,{:limit => 15})
      end
      should 'have rescued message' do
        assert_equal '<actual data is not being shown because truncate method failed.>', @output
      end
    end

  end

end
