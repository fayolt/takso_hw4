defmodule Takso.Geolocator do
    @http_client Application.get_env(:takso, :http_client)
  
    defp process_address(address) do
        city = "Tartu"
        country = "Estonia"
        address 
        |> String.replace(" ", "+")
        |> (&(&1 <> &2)).("+#{city}+#{country}")
    end
    
    def trip_duration(origin, destination) do
        
        origin = process_address(origin)
        destination = process_address(destination)
        
        %{body: body} = @http_client.get!(
            "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origin}&destinations=#{destination}")
        %{"rows" => [%{"elements" => [%{"duration" => %{"text" => duration_text}}]}]} = Poison.Parser.parse!(body)
        duration_text
    end
    def time_to_pickup(origins, destination) do
        origins_string = 
            Enum.map(origins, fn origin -> process_address(origin) end)
            |> Enum.join("|")
        destination = process_address(destination)
        %{body: body} = @http_client.get!(
            "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origins_string}&destinations=#{destination}")
        %{"rows" => rows} = Poison.Parser.parse!(body)
        
        {min, ind} = get_min_and_index(Enum.map(rows, fn element -> extract_duaration(element) end))
        
        # %{"origin_addresses" => locations} = Poison.Parser.parse!(body)
        # {min, Enum.at(locations, ind) |> String.split(",") |> hd}
        {min, Enum.at(origins, ind)}
    end

    defp extract_duaration(element) do
        %{"elements" => [%{"duration" => %{"text" => duration_text}}]} = element
        {duration, _} = Integer.parse duration_text
        duration
    end

    defp get_min_index([], acc) do
        acc
    end
    defp get_min_index(aList, acc) do
        if hd(aList) == Enum.min(aList) do
            acc
        else
            get_min_index(tl(aList), acc+1)
        end
    end

    defp get_min_and_index(aList) do
        {Enum.min(aList), get_min_index(aList, 0)}
    end
end