Feature: quick search

  Scenario: quick search with no search term
    Given the following user exists:
      | first_name | last_name |
      | Mary       | Jane      |
      | John       | Smith     |
      | Neil       | Singh     |
      | Trisha     | Singh     |
    Given I visit quick_search page
    Then first id of table should be of "Trisha"
    Then I should see "Next →"
    Then I follow "Next →"
    Then verify that user "first_name" is "John"
    Then verify that user "last_name" is "Smith"

  @javascript
  Scenario: quick search with no search term for Newspaper which has paper_id as primary key
    Given a newspaper exists
    Given I visit admin_data page
    When I select "newspaper" from "drop_down_klasses"
    Then I should see "Listing Newspaper"

  @javascript
  Scenario: quick search with no search term for City which has to_model declared
    Given a city exists
    Given I visit admin_data page
    When I select "city" from "drop_down_klasses"
    Then I should see "Listing City"
    When I follow "seattle"
    Then I should see "seattle"
    Then I should see population_5000

  Scenario: sorting
    Given the following user exists:
      | first_name | last_name |
      | Mary       | Jane      |
      | John       | Smith     |
    Given I visit quick_search page
    When I select "id asc" from "sortby"
    When I press "Search"
    Then verify that user "first_name" is "Mary"
    Then verify that user "last_name" is "Jane"

  Scenario: quick search with search term
    Given the following user exists:
      | first_name | last_name |
      | Mary       | Jane      |
      | John       | Smith     |
    Given I visit quick_search page
    When I fill in "quick_search_input" with "John"
    When I press "Search"
    Then I should see "Search result: 1 record found"
    Then verify that user "first_name" is "John"
    Then verify that user "last_name" is "Smith"

  Scenario: quick search with search term with association info
    Given the following user exists:
      | first name | last name |
      | Mary       | Jane      |
    Given the following phone number exists:
      | number        | user            |
      | 123-456-7890  | first name:Mary |
      | 123-456-7777  | first name:Mary |
    When I visit quick search page with association info page
    Then I should see "has 2 phone_numbers"
    Then I should see only two rows in the quick search result table

  Scenario: quick search with wrong klass name
    When I visit quick search with wrong klass name page
    Then I should see "wrong params[:klass] was supplied"

  Scenario: quick search with wrong base klass name
    Given the following user exists:
      | first name | last name |
      | Mary       | Jane      |
    When I visit quick search with wrong base klass name page
    Then I should see "user_wrong is an invalid value"

  Scenario: quick search with wrong children klass name
    Given the following user exists:
      | first name | last name |
      | Mary       | Jane      |
    When I visit quick search with wrong children klass name page
    Then I should see "phone_numbers_wrong is not a valid has_many association"

  @javascript
  Scenario: quick search for website with custom columns order
    Given a website exists
    Given I visit admin_data page
    When I select "website" from "drop_down_klasses"
    Then I should see tabular attributes for website with custom columns order

  @javascript
  Scenario: quick search for city with custom columns header
    Given a city exists
    Given I visit admin_data page
    When I select "city" from "drop_down_klasses"
    Then I should see tabular attributes for city with custom column headers

  @javascript
  Scenario: quick search for User with has_many info
    Given the following user exists:
      | first name | last name |
      | Mary       | Jane      |
    Given the following phone number exists:
      | number        | user            |
      | 123-456-7890  | first name:Mary |
      | 123-456-7899  | first name:Mary |
    Given user config has defined additional_column phone_numbers
    Given I visit admin_data page
    When I select "user" from "drop_down_klasses"
    Then table should have additional column phone_numbers with valid data


