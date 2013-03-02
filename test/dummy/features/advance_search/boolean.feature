Feature: Advance Search for boolean

  @javascript
  Scenario: Advance Search for a boolean
    Given a user exists
    Given I visit advance_search page
    When I select "active" from "adv_search[1_row][col1]"
    Then page should have css "#advance_search_table tr td select.col2"
    When I select "is null" from "adv_search[1_row][col2]"
    #Then page should have disabled css "#advance_search_table tr td input.col3"
    When I select "is not null" from "adv_search[1_row][col2]"
    #Then page should have disabled css "#advance_search_table tr td input.col3"
    When I select "is true" from "adv_search[1_row][col2]"
    #Then page should have disabled css "#advance_search_table tr td input.col3"
    When I select "is false" from "adv_search[1_row][col2]"
    #Then page should have disabled css "#advance_search_table tr td input.col3"

  @javascript
  Scenario: option "is false"
    Given the following user exists:
      | first name | last name | active |
      | John       | Smith     | false  |
      | Mary       | Jane      | true   |
    Given I visit advance_search page
    When I select "active" from "adv_search[1_row][col1]"
    When I select "is false" from "adv_search[1_row][col2]"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"

  @javascript
  Scenario: option "is true"
    Given the following user exists:
      | first name | last name | active |
      | Mary       | Jane      | true   |
      | John       | Smith     | false  |
    Given I visit advance_search page
    When I select "active" from "adv_search[1_row][col1]"
    When I select "is true" from "adv_search[1_row][col2]"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "Mary"
    Then async verify that user "last_name" is "Jane"

  @javascript
  Scenario: option "is null"
    Given the following user exists:
      | first name | last name | active |
      | John       | Smith     | false  |
      | Mary       | Jane      | true   |
    Given first user's value for active is nil
    Given I visit advance_search page
    When I select "active" from "adv_search[1_row][col1]"
    When I select "is null" from "adv_search[1_row][col2]"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"

  @javascript
  Scenario: option "is not null"
    Given the following user exists:
      | first name | last name | active |
      | Mary       | Jane      | true   |
      | John       | Smith     | false  |
    Given last user's value for active is nil
    Given I visit advance_search page
    When I select "active" from "adv_search[1_row][col1]"
    When I select "is not null" from "adv_search[1_row][col2]"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "Mary"
    Then async verify that user "last_name" is "Jane"
