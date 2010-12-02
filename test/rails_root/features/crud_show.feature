Feature: CRUD show

  Scenario: show
    Given a user exists
    Given I visit user show page
    Then I should notice id of the last person
    Then I should see "Edit"
    Then I should see "Delete"
    Then I should see "Destroy"
    Then I should see crud show tabular attributes

  Scenario: show with has_one association info
    Given the following user exists:
      | first name | last name |
      | Mary       | Jane      |
    Given the following website exists:
      | url             | user            |
      | www.google.com  | first name:Mary |
    Given I visit user show page
    Then I should see "website"
    When I follow "website"
    Then I should notice id of website of the last person
    When I follow "user"
    Then I should notice id of the last person

  Scenario: show with has_many association info
    Given the following user exists:
      | first name | last name |
      | Mary       | Jane      |
    Given the following phone number exists:
      | number        | user            |
      | 123-456-7890  | first name:Mary |
      | 123-456-7899  | first name:Mary |
    Given I visit user show page
    Then I should see "phone_numbers(2)"
    When I follow "phone_numbers(2)"
    Then I should see "has 2 phone_numbers"

  Scenario: show with habtm association info
    Given the following user exists:
      | first name | last name |
      | Mary       | Jane      |
    Given user owns two clubs "sun-shine" and "rise-n-shine"
    Given I visit user show page
    Then I should see "clubs(2)"
    When I follow "clubs(2)"
    Then I should see "has 2 clubs"
