module AdminDataTasks
  def self.copy_views_to_app
    FileUtils.cp_r("#{File.dirname(__FILE__)}/../../app/views/admin_data", 
                   "#{RAILS_ROOT}/app/views")
    puts "Copied the Admin Data views into your project in #{File.dirname(__FILE__)}/../../app/views/admin_data"
    puts "These views will be found ahead of the ones in the plugin so go ahead and edit them to your application's look and feel."
  end
end
