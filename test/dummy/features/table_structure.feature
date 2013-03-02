Feature: table structure

  Scenario: table structure
    Given I visit quick_search page
    When I follow "Table Structure"
    Then I should see "Table name : users"
    Then I should see following tabular attributes:
     |Column Name  | Type     | Null  | Default |
     | id          | integer  | false |         | 
     | first_name  | string   | true  |         | 
     | last_name   | string   | true  |         | 
     | age         | integer  | true  |         | 
     | data        | text     | true  |         | 
     | active      | boolean  | true  | false   | 
     | description | text     | true  |         | 
     | born_at     | datetime | true  |         | 
     | created_at  | datetime | true  |         | 
     | updated_at  | datetime | true  |         | 
