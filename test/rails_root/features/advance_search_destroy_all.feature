Feature: Advance search destroy all

  @javascript
  Scenario: destroy all
    Given the following user exists:
      | first name | last name |
      | John       | Smith     |
      | Mary       | Jane      |
      | Jennifer   | Jane      |
    Given I visit advance_search page
    When I select "first_name" from "adv_search[1_row][col1]"
    When I select "is exactly" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "John"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"
    When async click "Destroy All"
    Then async verify that number of "User" records is "2"
    Then asyc I should see "1 record destroyed"
