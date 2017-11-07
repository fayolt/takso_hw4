Feature: Taxi selection by proximity
  As an automated system (STRS)
  Such that our customers can be picked up in a short term
  I want to select the taxi that is closest to the pick up address

  Scenario Outline: Booking via STRS' web page (with confirmation)
    Given the following taxis are on duty
          | username | location	   |
          | taxi1    | Soola 4     |
          | taxi2    | Vanemuise 4 |
          | taxi3    | Vaksali 6   |
          | taxi4    | Umera 1     |
          | taxi5    | Ringtee 75  |
    And I want to go from "<pickup_address>" to "<dropoff_address>"
    And I open STRS' web page
    And I enter the booking information
    When I summit the booking request
    Then I should be notified that my taxi will arrive in "<time_to_pickup>"
    And that the estimated trip duration will be of "<trip_duration>"

    Examples:
        | pickup_address   | dropoff_address | time_to_pickup | trip_duration |
        | Liivi 2          | Riia 132        | 4 mins         | 8 mins        |
        | Raatuse 22       | Kreutzwaldi 1   | 3 mins         | 7 mins        |
        | Tamme puiestee 1 | Turu 10         | 3 mins         | 7 mins        |
        | Kastani 1        | Voru 167        | 2 mins         | 10 mins       |