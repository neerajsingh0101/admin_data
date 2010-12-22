unless Rails.version >= '3.0'
  msg = []
  msg << "It seems you are not using Rails 3."
  msg << "Please see documentation at"
  msg << "http://github.com/neerajdotname/admin_data/wiki"
  msg << "to find out how to use this gem with rails 2.3.x"
  raise msg.join(' ')
end
