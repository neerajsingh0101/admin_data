# Usage:
#
# Then page should have "select" field with selector "#phone_number_user_id"
# Then page should have "input" field with selector "#phone_number_user_id"
Then /^page should have "(.*)" field with selector "(.*)"$/ do |tag_name, css_selector|
  elem = page.find(css_selector)
  elem.tag_name.should == tag_name
  elem.value.should == PhoneNumber.last.user.id.to_s
end

Then /^page should have id "remove_row_3"$/ do
  page.has_css?("remove_row_3")
end

Then /^I should see "(.*)" rows in table "(.*)"$/ do |count, table_id|
  table =  page.find(:xpath, "//table[@id='#{table_id}']")
  table.find(:xpath, "./tbody/tr", :count => count.to_i )
end

Then /^async I should see "(.*)"$/ do |msg|
  page.should have_content(msg)
end

Then /^page should have css "(.*)"$/ do |css_selector|
  page.should have_css(css_selector)
end

Then /^page should have disabled css "(.*)"$/ do |css_selector|
  elem = page.find(css_selector)
  elem['disabled'].should == 'true'
end

def handy_has_links(table)
  table.hashes.each do |h|
    css_selector = h[:within]
    selector = css_selector[1..-1]
    page.should have_xpath( "//div[@id='#{selector}']//a[@href='#{h[:url]}']", :text => h[:text] )
  end
end

# Usage:
#
# Then page should have following links:
#  | url                                                | text          | within  |
#  | http://github.com/neerajdotname/admin_data         | admin_data    | #footer |
#  | http://github.com/neerajdotname/admin_data/issues  | Report Bug    | #footer |
#  | http://github.com/neerajdotname/admin_data/wiki    | Documentation | #footer |
Then /^page should have following links?:$/ do |table|
  handy_has_links(table)
end


# Usage :
#
#  position:         if the option is the very first option in the dropdown list then position should be 1.
#  css_selector:     only class and id are supported at this time.
#  value_match_type: If specified as "regex" then Regular expression will be used to detect the match.
#
#  Then I should see dropdown with css_selector ".drop_down_value_klass" with following options:
#    | text         | value                                 | position | value_match_type |
#    | phone_number | /admin_data/quick_search/phone_number | 2        | regex            |
#    | user         | /admin_data/quick_search/user         | 3        | regex            |
#    | website      | /admin_data/quick_search/website      | 4        | regex            |
#
def handy_has_select?(css_selector, select_options)
  selector = css_selector[1..-1]
  case css_selector[0,1]
  when '.'
    attribute = "@class='#{selector}'"
  when '#'
    attribute = "@id='#{selector}'"
  else
    raise 'only css_selector class or id is currently supported'
  end

  page.should have_xpath("//select[#{attribute}]")
  selects = page.find(:xpath, "//select[#{attribute}]")

  select_options.each do |h|
    selects.find(:xpath, "./option[#{h[:position]}]", :text => h[:text])
    if h[:value_match_type] == 'regex'
      selects.find(:xpath, "./option[#{h[:position]}]").value.should match Regexp.new(h[:value])
    else
      selects.find(:xpath, "./option[#{h[:position]}]", :text => h[:value])
    end
  end
end

Then /^I should see dropdown with css_selector "(.*)" with following options:$/ do |css_selector, table|
  handy_has_select?(css_selector, table.hashes)
end
