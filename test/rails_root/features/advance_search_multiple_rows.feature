Feature: Advance search multiple rows

  @javascript
  Scenario: two rows
    Given the following user exists:
      | first name | last name | age |
      | Mary       | Jane      | 30  |
      | Jennifer   | Jane      | 30  |
      | John       | Smith     | 40  |
      | John       | Vander    | 30  |
    Given I visit advance_search page
    When I select "first_name" from "adv_search[1_row][col1]"
    When I select "is exactly" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "John"

    When I follow "add_row_link_1"

    When I select "last_name" from "adv_search[2_row][col1]"
    When I select "is exactly" from "adv_search[2_row][col2]"
    When I fill in "adv_search[2_row][col3]" with "Smith"

    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"


  @javascript
  Scenario: three rows
    Given the following user exists:
      | first name | last name | age |
      | John       | Smith     | 40  |
      | John       | Smith     | 30  |
      | Mary       | Jane      | 30  |
      | Mary       | Jane      | 40  |
      | Jennifer   | Jane      | 30  |
    Given I visit advance_search page
    When I select "first_name" from "adv_search[1_row][col1]"
    When I select "is exactly" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "John"

    When I follow "add_row_link_1"
    When I select "last_name" from "adv_search[2_row][col1]"
    When I select "is exactly" from "adv_search[2_row][col2]"
    When I fill in "adv_search[2_row][col3]" with "Smith"

    When I follow "add_row_link_1"
    When I select "age" from "adv_search[3_row][col1]"
    When I select "is equal to" from "adv_search[3_row][col2]"
    When I fill in "adv_search[3_row][col3]" with "40"

    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"

  @javascript
  Scenario: First built two extra rows and then kill the last row
    Given the following user exists:
      | first name | last name | age |
      | Mary       | Jane      | 30  |
      | Jennifer   | Jane      | 30  |
      | John       | Smith     | 40  |
      | John       | Smith     | 30  |
    Given I visit advance_search page
    When I select "first_name" from "adv_search[1_row][col1]"
    When I select "is exactly" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "John"
    
    When I follow "add_row_link_1"
    When I select "last_name" from "adv_search[2_row][col1]"
    When I select "is exactly" from "adv_search[2_row][col2]"
    When I fill in "adv_search[2_row][col3]" with "Smith"

    When I follow "add_row_link_1"
    When I select "age" from "adv_search[3_row][col1]"
    When I select "is equal to" from "adv_search[3_row][col2]"
    When I fill in "adv_search[3_row][col3]" with "40"
    
    Then page should have id "remove_row_3"

    When I follow "remove_row_3"
    Then I should see only two rows in the table
    When I press "Search"
    Then I should see "Search result: 2 records found"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"
