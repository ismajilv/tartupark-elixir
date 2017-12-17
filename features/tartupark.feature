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
    Then User enter the parking address of "<destinations>", "<payment_type>", "<start_date>", "<end_date>" and "<search_radius>"
    And User press choose


    Examples:
        | destinations     | payment_type    | start_date | end_date | search_radius  |
        | Tamme puiestee 1 | Hourly          | Vanemuise  | 4:20     | 500            |
