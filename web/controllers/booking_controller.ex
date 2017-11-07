defmodule Takso.BookingController do
  use Takso.Web, :controller
  import Ecto.Query, only: [from: 2]

  alias Takso.{Taxi, Booking, Repo, Allocation}
  alias Ecto.{Multi, Changeset}
  
  # plug :authorize_resource, model: Booking, non_id_actions: [:summary]

  def index(conn, _params) do
    bookings = Repo.all(from b in Booking, select: b)
    render conn, "index.html", bookings: bookings
  end

  def new(conn, _params) do
    render conn, "new.html", changeset: Booking.changeset(%Booking{})
  end

  def summary(conn, _params) do
    query = from t in Taxi,
            join: a in Allocation, on: t.id == a.taxi_id,
            group_by: t.username,
            where: a.status == "accepted",
            select: {t.username, count(a.id)}
    render conn, "summary.html", tuples: Repo.all(query)
  end

  def create(conn, %{"booking" => booking_params}) do
    
    changeset = Booking.changeset(%Booking{}, booking_params)
                |> Changeset.put_change(:status, "open")

    query = from t in Taxi, where: t.status == "available", select: t
    available_taxis = Repo.all(query)
    if length(available_taxis) > 0 do
      booking = Repo.insert!(changeset)
      trip_duration = Takso.Geolocator.trip_duration(booking_params["pickup_address"], booking_params["dropoff_address"])      
      
      addresses = Enum.map(available_taxis, fn taxi -> taxi.location end)
      {time, location} = Takso.Geolocator.time_to_pickup(addresses, booking_params["pickup_address"])

      taxi = Enum.find(available_taxis, fn t -> t.location == location end)

      Multi.new
      |> Multi.insert(:allocation, Allocation.changeset(%Allocation{}, %{status: "accepted"}) |> Changeset.put_change(:booking_id, booking.id) |> Changeset.put_change(:taxi_id, taxi.id))
      |> Multi.update(:taxi, Taxi.changeset(taxi) |> Changeset.put_change(:status, "busy"))
      |> Multi.update(:booking, Booking.changeset(booking) |> Changeset.put_change(:status, "allocated"))
      |> Repo.transaction

      conn
      |> put_flash(:info, "Your taxi will arrive in #{time} mins. The estimated duration of your trip is of #{trip_duration} mins")
      |> redirect(to: booking_path(conn, :index))
    else
      conn
      |> put_flash(:error, "We apologize, we cannot serve your request in this moment")
      |> redirect(to: booking_path(conn, :index))
    end
  end
end
