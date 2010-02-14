require File.join(File.dirname(__FILE__) ,'..', 'test_helper')

require File.expand_path(File.join(File.dirname(__FILE__), '../../../admin_data/lib/admin_data/util.rb'))

class AdminDataUtilTest < Test::Unit::TestCase

  context 'writing to validation file test' do
    setup do
      tid = '123456'
      filename = 'testing.txt'
      mode = 'w'
      data = 'hello world'
      AdminData::Util.write_to_validation_file(data, mode, tid, filename)
      file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid, filename)
      @text = File.readlines(file)
    end
    should 'have written to file' do
      assert_equal 'hello world', @text.last.strip 
    end
  end

  context 'has_one' do
    subject { AdminData::Util.has_one_what(Vehicle::Car) }
    setup { @instance = Vehicle::Car.create(:year => 2000, :brand => 'bmw') }
    should 'be engine' do
      assert subject
      assert subject.size,1
      assert_equal 'engine', subject[0] 
    end
    should 'respond_to? has_one' do
      assert @instance.respond_to?(subject[0])
    end
  end

  context 'columns_order default order' do
    setup do
      AdminDataConfig.set = {:columns_order => nil }
      @output = AdminData::Util.columns_order('Article')
    end
    should 'have created_at and updated_at at the very end' do
      assert_equal %w(article_id title body body_html short_desc status published_at approved hits_count
      magazine_type magazine_id data created_at updated_at
      ), @output
    end
  end

  context 'columns_order custom order' do
    setup do
      AdminDataConfig.set = {:columns_order => {'Article' => [:article_id, :body, :published_at] }}
      @output = AdminData::Util.columns_order('Article')
    end
    should 'have right order' do
      assert_equal %w(article_id body published_at title body_html short_desc status approved hits_count
      magazine_type created_at updated_at magazine_id data
      ),
      @output
    end
  end

  context 'oracle test' do
    setup do
      AdminDataConfig.setting.merge!(:adapter_name => 'Oracle')
      @term = Search::Term.new(Article,{:col1 => 'body_html', :col2 => 'contains', :col3 => 'foo'}, 'quick_search')
    end
    teardown do
      AdminDataConfig.setting.merge!(:adapter => 'MySQL')
    end
    should 'have proper sql' do
      assert_equal ["upper(articles.body_html) LIKE ?", "%FOO%"], @term.attribute_condition
    end
  end

  context 'postgresql test' do
    setup do
      AdminDataConfig.setting.merge!(:adapter_name => 'PostgreSql')
      @term = Search::Term.new(Article,{:col1 => 'body_html', :col2 => 'contains', :col3 => 'foo'}, 'quick_search')
    end
    teardown do
      AdminDataConfig.setting.merge!(:adapter => 'MySQL')
    end
    should 'have proper sql' do
      assert_equal ["articles.body_html ILIKE ?", "%foo%"], @term.attribute_condition
    end
  end

  context 'mysql test' do
    setup do
      AdminDataConfig.setting.merge!(:adapter_name => 'MySQL')
      @term = Search::Term.new(Article,{:col1 => 'body_html', :col2 => 'contains', :col3 => 'foo'}, 'quick_search')
    end
    teardown do
      AdminDataConfig.setting.merge!(:adapter => 'MySQL')
    end
    should 'have proper sql' do
      assert_equal ["articles.body_html LIKE ?", "%foo%"], @term.attribute_condition
    end
  end

end
