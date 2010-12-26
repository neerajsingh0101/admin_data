When /^I visit (.*) page$/ do |target_page|
  case target_page
  when 'admin_data'
    visit '/admin_data'

  when 'quick_search'
    visit '/admin_data/quick_search/user'

  when 'advance_search'
    visit '/admin_data/advance_search/user'

  when 'user show'
    visit "/admin_data/klass/user/#{User.last.id}"

  when 'phone_number show'
    visit "/admin_data/klass/phone_number/#{PhoneNumber.last.id}"

  when 'newspaper show'
    visit "/admin_data/klass/newspaper/#{Newspaper.last.paper_id}"

  when 'user feed'
    visit "/admin_data/feed/user"

  when 'quick search page with association info'
    visit "/admin_data/quick_search/phone_number?base=user&children=phone_numbers&model_id=#{User.last.id}"

  when 'quick search with wrong klass name'
    visit "/admin_data/quick_search/phone_number_wrong"

  when 'quick search with wrong base klass name'
    visit "/admin_data/quick_search/phone_number?base=user_wrong&children=phone_numbers&model_id=#{User.last.id}"

  when 'quick search with wrong children klass name'
    visit "/admin_data/quick_search/phone_number?base=user&children=phone_numbers_wrong&model_id=#{User.last.id}"
  end
end
