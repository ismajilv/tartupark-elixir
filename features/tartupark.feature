Feature: Parking allocation
  As an automated system (STRS)
  Such that parking spaces can be allocated
  I want to get the information about the parking space that are closer to the destination address
        and book the available parking space
  Scenario Outline: Parking via web browser
      Given the following person
          | fullName      | username | password | email     | license_number |
          | Name          | username | 1parool   | 1ns@ns.com | 1ns123     |
    When I enter the booking information on the STRS Customer app
    Then I press the registration button
    And I fill the registration page with my details and submit
    And The web page is directed to Main page
    When I enter the parlking address of "<destinations>"
    Then I specify payment type of "<payment_type>"
    And I specify start date of "<start_date>"
    And I specify start date of "<end_date>"
    And I spesify search radius of "<search_radius>"
    And I want to park my car in "<street choice>"
    And I press choose
    And I get notification of "<notification>"
    When Payment method is Hourly and payment time is Before Parking
    Then I add credit card details
    And I submit payment
    When Payment method is Hourly and payment time is End of month
    Then I redirected to main page
    When Payment method is Real time and payment time is Before Parking
    Then I directed to main page

    Examples:
        | destinations     | real_time_configured    | start_date | payment_type | street_choice  | payment_choice  | start_time_choice | end_time_choice | notification |
        | Tamme puiestee 1 | yes (balance 12.5 euro) | | |Vanemuise      | hourly          | 15:00             | 15:20           | parking space for 20 mins is booked and your fee is 2 euros |
