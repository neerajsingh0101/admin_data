Feature: RSS feed availabilty for all the models

  Scenario: RSS feed availability with invalid authentication
    Given a user exists
    When mocked feed authentication returns false
    Given I visit user feed page
    Then I should see "not authorized"

  Scenario: RSS feed availability with valid authentication
    Given a user exists
    When mocked feed authentication returns true
    Given I visit user feed page
    Then I should see "Feeds from admin_data User"
