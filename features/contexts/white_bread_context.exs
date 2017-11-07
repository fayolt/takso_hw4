defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers
  alias Takso.{Repo,Taxi}
  
  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)    
    %{}
  end
  scenario_starting_state fn state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(Takso.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Takso.Repo, {:shared, self()})
    %{}
  end
  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Takso.Repo)
    # Hound.end_session
  end 

  given_ ~r/^the following taxis are on duty$/, 
  fn state, %{table_data: table} ->
    table
    |> Enum.map(fn taxi -> Taxi.changeset(%Taxi{}, taxi) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}
  end
  and_ ~r/^I want to go from "(?<pickup_address>[^"]+)" to "(?<dropoff_address>[^"]+)"$/,
  fn state, %{pickup_address: pickup_address, dropoff_address: dropoff_address} ->
    {:ok, state |> Map.put(:pickup_address, pickup_address) |> Map.put(:dropoff_address, dropoff_address)}
  end
  and_ ~r/^I open STRS' web page$/, fn state ->
    navigate_to "/bookings/new"
    {:ok, state}
  end
  and_ ~r/^I enter the booking information$/, fn state ->
    fill_field({:id, "pickup_address"}, state[:pickup_address])
    fill_field({:id, "dropoff_address"}, state[:dropoff_address])    
    {:ok, state}
  end
  when_ ~r/^I summit the booking request$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end
  then_ ~r/^I should be notified that my taxi will arrive in "(?<expected_eta>[^"]+)"$/,
  fn state, %{expected_eta: expected_eta} ->
    assert visible_in_page? ~r/Your taxi will arrive in \d+ mins/
    flash = visible_text(find_element(:css, ".alert-info"))
    %{"actual_eta" => actual_eta} = Regex.named_captures ~r/arrive\D+(?<actual_eta>\d+ mins)/, flash
    assert expected_eta == actual_eta
    {:ok, state}
  end
  and_ ~r/^that the estimated trip duration will be of "(?<expected_duration>[^"]+)"$/,
  fn state, %{expected_duration: expected_duration} ->
    assert visible_in_page? ~r/The estimated duration of your trip is of \d+ mins/ 
    flash = visible_text(find_element(:css, ".alert-info"))
    %{"actual_duration" => actual_duration} = Regex.named_captures ~r/estimated\D+(?<actual_duration>\d+ mins)/, flash
    assert expected_duration == actual_duration
    {:ok, state}
  end
end