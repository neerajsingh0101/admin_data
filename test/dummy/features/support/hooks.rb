
Before do

  # Reset the configuration since it might have been modified by a step in 
  # another senario.
  AdminData.configuration = nil
  load File.join( Rails.root, 'config', 'initializers', 'admin_data.rb')

end