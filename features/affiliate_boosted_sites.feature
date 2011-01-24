Feature: Boosted Sites
  In order to boost specific sites to the top of search results
  As an affiliate
  I want to manage boosted sites
  

  Scenario: Create a new Boosted Site
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted sites"
    And I fill in "Title" with "Test"
    And I fill in "Url" with "http://www.test.gov"
    And I fill in "Description" with "Test Description"
    And I press "Save Boosted Site"
    Then I should be on the new affiliate boosted site page
    And I should see "Test" within "#boosted_sites"
    And I should see "http://www.test.gov" within "#boosted_sites"
    And I should see "Test Description" within "#boosted_sites"

  Scenario: Edit a Boosted Site
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And the following Boosted Sites exist for the affiliate "aff.gov"
     | title            | url               | description     |
     | a title          | http://a.url.gov  | A description    |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted sites"
    And I follow "Edit"
    Then I should be on the edit affiliate boosted site page
    And I fill in "Title" with "new title"
    And I fill in "Description" with "new description"
    And I press "Save Boosted Site"
    Then I should be on the new affiliate boosted site page
    And I should see "new title" within "#boosted_sites"
    And I should not see "a title" within "#boosted_sites"
    And I should see "http://a.url.gov" within "#boosted_sites"
    And I should see "new description" within "#boosted_sites"
    And I should not see "a description" within "#boosted_sites"

  Scenario: Site visitor sees relevant boosted results for given affiliate search
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
      | bar.gov          | aff@bar.gov           | John Bar            |
    And the following Boosted Sites exist for the affiliate "aff.gov"
      | title               | url                     | description                               |
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
      | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And the following Boosted Sites exist for the affiliate "bar.gov"
      | title               | url                     | description                               |
      | Bar Emergency Page  | http://www.bar.gov/911  | This should not show up in results        |
      | Pelosi misspelling  | http://www.bar.gov/pel  | Synonyms file test works                  |
      | all about agencies  | http://www.bar.gov/pel  | Stemming works                            |
    When I go to aff.gov's search page
    And I fill in "query" with "emergency"
    And I submit the search form
    Then I should see "Our Emergency Page" within "#boosted"
    And I should see "FAQ Emergency Page" within "#boosted"
    And I should not see "Our Tourism Page" within "#boosted"
    And I should not see "Bar Emergency Page" within "#boosted"

    When I go to bar.gov's search page
    And I fill in "query" with "Peloci"
    And I submit the search form
    Then I should see "Synonyms file test works" within "#boosted"

    When I go to bar.gov's search page
    And I fill in "query" with "agency"
    And I submit the search form
    Then I should see "Stemming works" within "#boosted"

  Scenario: Uploading valid booster XML document as a logged in affiliate
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted sites"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > aff.gov > Boosted Sites"
    Then I should see "aff.gov has no boosted sites"
    And I should see "Bulk Upload Boosted Sites for aff.gov"

    When I attach the file "features/support/boosted_sites.xml" to "xml_file"
    And I press "Upload"
    Then I should see "Boosted sites uploaded successfully for affiliate 'aff.gov'"

    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted sites"
    Then I should see "This is a listing about Texas"
    And I should see "Some other listing about hurricanes"
    And I should see "Bulk Upload Boosted Sites for aff.gov"

    When I attach the file "features/support/new_boosted_sites.xml" to "xml_file"
    And I press "Upload"
    And I follow "Boosted sites"
    Then I should see "New results about Texas"
    And I should see "New results about hurricanes"

  Scenario: Uploading invalid booster XML document as a logged in affiliate
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
    And the following Boosted Sites exist for the affiliate "aff.gov"
      | title               | url                     | description                               |
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
      | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted sites"
    And I attach the file "features/support/missing_title_boosted_sites.xml" to "xml_file"
    And I press "Upload"
    Then I should see "Your XML document could not be processed. Please check the format and try again."
    And I should see "Our Emergency Page"
    And I should see "FAQ Emergency Page"
    And I should see "Our Tourism Page"

    When I go to aff.gov's search page
    And I fill in "query" with "tourism"
    And I submit the search form
    Then I should see "Our Tourism Page" within "#boosted"

