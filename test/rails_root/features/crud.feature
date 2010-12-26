Feature: CRUD

  Scenario: edit
    Given a user exists
    Given I visit user show page
    Given I follow "Edit"
    When I fill in the following:
      | user_first_name ||
      | user_age        ||
    When I press "Update"
    Then I should see "First name can't be blank"
    Then I should see "Age can't be blank"
    Then I should see "Age is not a number"
    Then I should find value "(auto)" for "created_at"
    Then I should find value "(auto)" for "updated_at"
    When I fill in the following:
      | user_first_name | Robert2 |
      | user_age        | 99      |
    When I press "Update"
    Then I should see "Robert2"
    Then I should see "99"
    Then I should see "Record was updated"

  Scenario: edit PhoneNumber (no association drop-down)
    Given configuration to hide the association drop down for PhoneNumber
    Given a phone number exists
    Given I visit phone_number show page
    Given I follow "Edit"
    Then page should have "input" field with selector "#phone_number_user_id"

  Scenario: edit PhoneNumber (with association drop-down)
    Given configuration to show the association drop down for PhoneNumber
    Given a phone number exists
    Given I visit phone_number show page
    Given I follow "Edit"
    Then page should have "select" field with selector "#phone_number_user_id"

  Scenario: add a new record
    Given a user exists
    Given I visit quick_search page
    Given I follow "+Add New Record"
    Given I press "Create"
    Then I should see "First name can't be blank"
    Then I should see "Age can't be blank"
    Then I should see "Age is not a number"
    When I fill in the following:
      | user_first_name | Johny |
      | user_age        | 21    |
    When I press "Create"
    Then I should see "Record was created"
