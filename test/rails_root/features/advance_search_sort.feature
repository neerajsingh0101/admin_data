Feature: Advance Search

  @javascript
  Scenario: sorting
    Given the following user exists:
      | first name | last name | 
      | Mary       | Jane      |
      | John       | Smith     |
    Given I visit advance_search page
    When I press "Search"
    Then async verify that user "first_name" is "John"
    Then async verify that user "last_name" is "Smith"
    When I select "id asc" from "sortby"
    When I press "Search"
    Then async verify that user "first_name" is "Mary"
    Then async verify that user "last_name" is "Jane"
