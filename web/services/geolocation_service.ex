defmodule Takso.GeolocationService do
    
    def trip_duration(origin, destination) do
        origin = String.replace(origin, ",", "") |> String.replace(" ", "+")
        destination = String.replace(destination, ",", "") |> String.replace(" ", "+")
        %{body: body} = HTTPoison.get!(
            "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origin}&destinations=#{destination}")
        %{"duration_value" => value} = 
            Regex.named_captures ~r/duration\D+(?<duration_text>\d+ mins)\D+(?<duration_value>\d+)/, body
        Integer.parse(value) |> elem(0)
    end

end