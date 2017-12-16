Feature: Parking allocation
  As an automated system (STRS)
  Such that parking spaces can be allocated
  I want to get the information about the parking space that are closer to the destination address
        and book the available parking space
  Scenario Outline: Parking via web browser
    Given the following user
          | fullName      | username | password | email     | license_number |
          | Name          | username | parool   | ns@ns.com | ns123          |
    When User log in on the app
    Then User enter the parking address of "<destinations>"
    And User specify payment type of "<payment_type>"
    And User specify start date of "<start_date>"
    And User specify start date of "<end_date>"
    And User spesify search radius of "<search_radius>"
    And User want to park his car in "<street choice>"
    And User press choose
    And User enter the parking address of "<destinations>"
    And User specify payment type of "<payment_type>"
    And User specify start date of "<start_date>"
    And User specify start date of "<end_date>"
    And User spesify search radius of "<search_radius>"
    And User want to park his car in "<street choice>"
    And User press choose
    And User add payment details and pay
    And User enter the parking address of "<destinations>"
    And User specify payment type of "<payment_type>"
    And User specify start date of "<start_date>"
    And User specify start date of "<end_date>"
    And User spesify search radius of "<search_radius>"
    And User want to park his car in "<street choice>"
    And User press choose
    When User enter to booking history
    Then User see all booked places
    And User pay the booking place with end of month
    And User cancel all of them and return to main page

    Examples:
        | destinations     | real_time_configured    | start_date | payment_type | street_choice  | payment_choice  | start_time_choice | end_time_choice | notification |
        | Tamme puiestee 1 | yes (balance 12.5 euro) | | |Vanemuise      | hourly          | 15:00             | 15:20           | parking space for 20 mins is booked and your fee is 2 euros |
