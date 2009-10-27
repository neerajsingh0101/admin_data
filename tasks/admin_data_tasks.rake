namespace :admin_data do
  desc "Copy views from the admin_data plugin into your application (so you can customize them)"
  task :localize_views do
    require "#{File.dirname(__FILE__)}/../lib/admin_data/admin_data_tasks"
    AdminDataTasks.copy_views_to_app
  end
end
