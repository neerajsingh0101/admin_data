Feature: Advance Search for integer

  @javascript
  Scenario: Advance Search for an integer
    Given a user exists
    Given I visit advance_search page
    When I select "age" from "adv_search[1_row][col1]"
    Then page should have css "#advance_search_table tr td select.col2"
    When I select "is equal to" from "adv_search[1_row][col2]"
    Then page should have css "#advance_search_table tr td input.col3"
    When I select "is less than" from "adv_search[1_row][col2]"
    Then page should have css "#advance_search_table tr td input.col3"
    When I select "is greater than" from "adv_search[1_row][col2]"
    Then page should have css "#advance_search_table tr td input.col3"
    
  @javascript
  Scenario: option "is equal to"
    Given the following user exists:
      | first name | last name | age |
      | John       | Smith     | 40  |
      | Mary       | Jane      | 30  |
    Given I visit advance_search page
    When I select "age" from "adv_search[1_row][col1]"
    When I select "is equal to" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "40"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"

  @javascript
  Scenario: option "is less than"
    Given the following user exists:
      | first name | last name | age |
      | Mary       | Jane      | 30  |
      | John       | Smith     | 40  |
    Given I visit advance_search page
    When I select "age" from "adv_search[1_row][col1]"
    When I select "is less than" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "35"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "Mary"
    Then async verify that user "last_name" is "Jane"

  @javascript
  Scenario: option "is greater than"
    Given the following user exists:
      | first name | last name | age |
      | John       | Smith     | 40  |
      | Mary       | Jane      | 30  |
    Given I visit advance_search page
    When I select "age" from "adv_search[1_row][col1]"
    When I select "is greater than" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "35"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"

  @javascript
  Scenario: invalid integer value
    Given I visit advance_search page
    When I select "age" from "adv_search[1_row][col1]"
    When I select "is greater than" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "xyz"
    When I press "Search"
    Then async I should see "xyz is not a valid integer"

