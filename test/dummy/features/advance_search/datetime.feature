Feature: Advance Search datetime

  @javascript
  Scenario: test dropdown for datetime
    Given a user exists
    Given I visit advance_search page
    When I select "created_at" from "adv_search[1_row][col1]"
    Then page should have css "#advance_search_table tr td select.col2"
    When I select "is null" from "adv_search[1_row][col2]"
    #Then page should have disabled css "#advance_search_table tr td input.col3"
    When I select "is not null" from "adv_search[1_row][col2]"
    #Then page should have disabled css "#advance_search_table tr td input.col3"
    When I select "on" from "adv_search[1_row][col2]"
    Then async page should have text as current date for "#advance_search_table tr td input.col3" 
    When I select "on or before" from "adv_search[1_row][col2]"
    Then async page should have text as current date for "#advance_search_table tr td input.col3" 
    When I select "on or after" from "adv_search[1_row][col2]"
    Then async page should have text as current date for "#advance_search_table tr td input.col3" 

  @javascript
  Scenario: option "is null"
    Given the following user exists:
      | first name | last name | born_at          |
      | John       | Smith     |                  |
      | Mary       | Jane      | 03-November-2010 |
    Given I visit advance_search page
    When I select "born_at" from "adv_search[1_row][col1]"
    When I select "is null" from "adv_search[1_row][col2]"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"

  @javascript
  Scenario: option "is not null"
    Given the following user exists:
      | first name | last name | born_at          |
      | Mary       | Jane      | 03-November-2010 |
      | John       | Smith     |                  |
    Given I visit advance_search page
    When I select "born_at" from "adv_search[1_row][col1]"
    When I select "is not null" from "adv_search[1_row][col2]"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "Mary"
    Then async verify that user "last_name" is "Jane"

  @javascript
  Scenario: option "on"
    Given the following user exists:
      | first name | last name | born_at          |
      | Mary       | Jane      | 03-November-2010 |
      | John       | Smith     | 14-November-2010 |
    Given I visit advance_search page
    When I select "born_at" from "adv_search[1_row][col1]"
    When I select "on" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "03-November-2010"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "Mary"
    Then async verify that user "last_name" is "Jane"

  @javascript
  Scenario: option "on or after"
    Given the following user exists:
      | first name | last name | born_at          |
      | John       | Smith     | 14-November-2010 |
      | Mary       | Jane      | 03-November-2010 |
    Given I visit advance_search page
    When I select "born_at" from "adv_search[1_row][col1]"
    When I select "on or after" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "05-November-2010"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"

  @javascript
  Scenario: option "on or before"
    Given the following user exists:
      | first name | last name | born_at          |
      | Mary       | Jane      | 03-November-2010 |
      | John       | Smith     | 14-November-2010 |
    Given I visit advance_search page
    When I select "born_at" from "adv_search[1_row][col1]"
    When I select "on or before" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "05-November-2010"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "Mary"
    Then async verify that user "last_name" is "Jane"

  @javascript
  Scenario: invalid integer value
    Given I visit advance_search page
    When I select "born_at" from "adv_search[1_row][col1]"
    When I select "on" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "xyz"
    When I press "Search"
    Then async I should see "xyz is not a valid date"

