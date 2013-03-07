Feature: homepage

  @javascript
  Scenario: admin_data homepage
    Given the following user exists:
      | first_name | last_name |
      | Mary       | Jane      |
      | John       | Smith     |
      | Neil       | Singh     |
      | Trisha     | Singh     |
    Given I visit admin_data page
    Then I should see "Select from the drop down menu above"
    When I follow "admin_data" within "#subnav"
    Then I should see "Select from the drop down menu above"
    Then show me the page
    Then I should see dropdown with css_selector ".drop_down_value_klass" with following options:
      | text         | value                                 | position | value_match_type |
      | city         | /admin_data/quick_search/city         | 3        | regex |
      | club         | /admin_data/quick_search/club         | 4        | regex |
      | newspaper    | /admin_data/quick_search/newspaper    | 5        | regex |
      | phone_number | /admin_data/quick_search/phone_number | 6        | regex |
      | user         | /admin_data/quick_search/user         | 7        | regex |
      | website      | /admin_data/quick_search/website      | 8        | regex |

    Then I should see dropdown with css_selector "#drop_down_klasses" with following options:
      | text         | value                                 | position | value_match_type |
      | city         | /admin_data/quick_search/city         | 3        | regex            |
      | club         | /admin_data/quick_search/club         | 4        | regex            |
      | newspaper    | /admin_data/quick_search/newspaper    | 5        | regex            |
      | phone_number | /admin_data/quick_search/phone_number | 6        | regex            |
      | user         | /admin_data/quick_search/user         | 7        | regex            |
      | website      | /admin_data/quick_search/website      | 8        | regex            |
    When I select "user" from "drop_down_klasses"
    Then first id of table should be of "Trisha"

  Scenario: footer links
    Given I visit admin_data page
    Then page should have following links:
      | url                                                | text          | within  |
      | http://github.com/neerajdotname/admin_data         | admin_data    | #footer |
      | http://github.com/neerajdotname/admin_data/issues  | Report Bug    | #footer |
      | http://github.com/neerajdotname/admin_data/wiki    | Documentation | #footer |
