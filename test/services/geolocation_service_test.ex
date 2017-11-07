defmodule Takso.GeolocationServiceTest do
    use ExUnit.Case
    import Mock

    test_with_mock "Calls google maps api", HTTPoison, [get!: fn(_url) -> 
        %HTTPoison.Response{body: File.read! "Liivi_2__Lounakeskus.json"} end] do
         duration = Takso.GeolocationService.trip_duration("Liivi 2, Tartu, Estonia", "Lounakeskus, Tartu, Estonia")

        assert called HTTPoison.get!(
            "https://maps.googleapis.com/maps/api/distancematrix/json?origins=Liivi+2+Tartu+Estonia&destinations=Lounakeskus+Tartu+Estonia")
        
        assert duration == 560

    end
end