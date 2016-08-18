Feature: Admin views needs evaluation auctions in the admin panel
  As an admin of the Micro-purchase system
  I want to be able to view needs evaluation auctions

  Scenario: Admin sees data for needs evaluation auctions on the Needs Attention page
    Given there is a needs evaluation auction
    Given I am an administrator
    And I sign in
    Then I should be on the Needs Attention page
    When I click on the needs evaluation link
    Then I should see a table listing all needs evaluation auctions
    And I should see the auction title
