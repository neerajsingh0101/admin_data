Feature: Advance Search for string

  @javascript
  Scenario: Advance Search for a text field
    Given a user exists
    Given I visit advance_search page
    When I select "description" from "adv_search[1_row][col1]"
    Then page should have css "#advance_search_table tr td select.col2"
    When I select "Contains" from "adv_search[1_row][col2]"
    Then page should have css "#advance_search_table tr td input.col3"
    When I select "Doesn't Contain" from "adv_search[1_row][col2]"
    Then page should have css "#advance_search_table tr td input.col3"
    When I select "is null" from "adv_search[1_row][col2]"
    #Then page should have disabled css "#advance_search_table tr td input.col3"
    When I select "is not null" from "adv_search[1_row][col2]"
    #Then page should have disabled css "#advance_search_table tr td input.col3"


  @javascript
  Scenario: testing drop down behavior 
    Given a user exists
    Given I visit advance_search page
    Then page should have css "#advance_search_form"
    Then page should have css "#advance_search_table"
    Then page should have css "#advance_search_table tr td select.col1"
    When I select "first_name" from "adv_search[1_row][col1]"
    Then page should have css "#advance_search_table tr td select.col2"
    When I select "contains" from "adv_search[1_row][col2]"
    Then page should have css "#advance_search_table tr td input.col3"
    When I select "is exactly" from "adv_search[1_row][col2]"
    Then page should have css "#advance_search_table tr td input.col3"
    When I select "doesn't contain" from "adv_search[1_row][col2]"
    Then page should have css "#advance_search_table tr td input.col3"
    When I select "is null" from "adv_search[1_row][col2]"
    #Then page should have disabled css "#advance_search_table tr td input.col3"
    When I select "is not null" from "adv_search[1_row][col2]"
    #Then page should have disabled css "#advance_search_table tr td input.col3"
    
  @javascript
  Scenario: option "is not null"
    Given the following user exists:
      | first name | last name |
      | Mary       | Jane      |
      | John       |           |
    Given I visit advance_search page
    When I select "last_name" from "adv_search[1_row][col1]"
    When I select "is not null" from "adv_search[1_row][col2]"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "Mary"
    Then async verify that user "last_name" is "Jane"

  @javascript
  Scenario: option "is null"
    Given the following user exists:
      | first name | last name |
      | John       |           |
      | Mary       | Jane      |
      | Jennifer   | Jane      |
    Given I visit advance_search page
    When I select "last_name" from "adv_search[1_row][col1]"
    When I select "is null" from "adv_search[1_row][col2]"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then async verify that user "first_name" is "John"

  @javascript
  Scenario: option "is exactly"
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

  @javascript
  Scenario: option "contains"
    Given the following user exists:
      | first name | last name |
      | Mary       | Jane      |
      | Jennifer   | Jane      |
      | Jenny      | Aniston   |
      | John       | Smith     |
    Given I visit advance_search page
    When I select "first_name" from "adv_search[1_row][col1]"
    When I select "contains" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "Jenn"
    When I press "Search"
    Then I should see "Search result: 2 records found"
    Then async verify that user "first_name" is "Jenny"
    Then async verify that user "last_name" is "Aniston"

  @javascript
  Scenario: search for a text that does not exist 
    Given the following user exists:
      | first name | last name |
      | Mary       | Jane      |
      | Jennifer   | Jane      |
      | Jenny      | Aniston   |
      | John       | Smith     |
    Given I visit advance_search page
    When I select "first_name" from "adv_search[1_row][col1]"
    When I select "contains" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "xxxxxxxxxxxxx"
    When I press "Search"
    Then I should see "Search result: 0 records found"

  @javascript
  Scenario: option "does not contain"
    Given the following user exists:
      | first name | last name |
      | John       | Smith     |
      | Mary       | Jane      |
      | Jennifer   | Jane      |
      | Jenny      | Aniston   |
    Given I visit advance_search page
    When I select "first_name" from "adv_search[1_row][col1]"
    When I select "doesn't contain" from "adv_search[1_row][col2]"
    When I fill in "adv_search[1_row][col3]" with "Jenn"
    When I press "Search"
    Then I should see "Search result: 2 records found"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"
