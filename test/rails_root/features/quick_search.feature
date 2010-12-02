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
