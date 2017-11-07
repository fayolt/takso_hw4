defmodule Takso.HTTPoisonMock do
   
  defp process_address(address) do
    address 
    |> String.slice(0 .. String.length(address)-15) 
    |> String.replace(" ", "_")
  end
  def get!(url) do
      params_list = URI.query_decoder(URI.parse(url).query) |> Enum.to_list
      {_, origin} = params_list |> hd 
      [{_, destination}] = params_list |> tl
      source = 
        cond do
          origin =~ "|" -> process_address(destination) |> (&(&1 <> &2)).(".json")
          true -> process_address(origin) 
                  |> (&(&1 <> &2)).("__")
                  |> (&(&1 <> &2)).(process_address(destination))
                  |> (&(&1 <> &2)).(".json")
        end
      %HTTPoison.Response{
        body: File.read!("test/fixtures/#{source}")
      }

    end
end