defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers
  alias Takso.{Repo,Taxi, User}
  @decision_timeout Application.get_env(:takso, :decision_timeout)
  
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
    Hound.end_session
  end 
  given_ ~r/^the following taxis are on duty$/, 
  fn state, %{table_data: table} ->
    IO.puts "Decision timeout set to #{@decision_timeout} milliseconds"
    table
    |> Enum.map(fn taxi -> Taxi.changeset(%Taxi{}, taxi) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}
  end

  and_ ~r/^the status of the taxis is "(?<statuses>[^"]+)"$/,
  fn state, %{statuses: statuses} ->

    [%{name: "Soltan Garayev", username: "soltankara", password: "parool", role: "customer"},
     %{name: "Raza Rana", username: "taxi1", password: "parool", role: "taxi-driver"},
     %{name: "Eldar Hasanli", username: "taxi2", password: "parool", role: "taxi-driver"},
     %{name: "Meknun Rahman", username: "taxi3", password: "parool", role: "taxi-driver"}]
    |> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

    # IO.inspect "users are inserted!"

    String.split(statuses, ",")
    |> Enum.with_index
    |> Enum.map(fn {status, index} -> 
          Repo.get_by!(Taxi, username: "taxi#{index + 1}")
          |> Taxi.changeset(%{status: status})
          |> Repo.update!
        end)
    # IO.inspect "taxies are inserted!"
    {:ok, state}
  end

  and_ ~r/^I want to go from "(?<pickup_address>[^"]+)" to "(?<dropoff_address>[^"]+)"$/,
  fn state, %{pickup_address: pickup_address, dropoff_address: dropoff_address} ->
    {:ok, state |> Map.put(:pickup_address, pickup_address) |> Map.put(:dropoff_address, dropoff_address)}
  end 

  and_ ~r/^I enter the booking information on the STRS Customer app$/, fn state ->
    # 1. Insert a new user in the database (you can choose a username here)
    # [ %{name: "Soltan Garayev", username: "soltankara", password: "parool", role: "customer"},
      # %{name: "Polad Mahmudov", username: "poladmahmud", password: "parool", role: "customer"},
      # %{name: "Tural Ismailov", username: "turalismail", password: "parool", role: "customer"},
      # %{name: "Mansur Ali", username: "mansurali", password: "parool", role: "customer"},
      # %{name: "Raza Rana", username: "taxi1", password: "parool", role: "taxi-driver"},
      # %{name: "Eldar Hasanli", username: "taxi2", password: "parool", role: "taxi-driver"},
      # %{name: "Meknun Rahman", username: "taxi3", password: "parool", role: "taxi-driver"}]
    # |> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
    # |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

    # (Session :default will be used by customer)
    user_session = String.to_atom("soltankara" <> to_string(Enum.random(0..100000)))
    in_browser_session user_session, fn ->
      # 2. Log in the application with the user credentials
      navigate_to "/#/login"
      fill_field({:id, "username"}, "soltankara")
      fill_field({:id, "password"}, "parool")
      click({:id, "login-btn"})
      
      # IO.inspect "user logged in!"

      # 3. Enter the information about the booking
      fill_field({:id, "pickup_address"}, state[:pickup_address]<>", Tartu, Estonia")
      fill_field({:id, "dropoff_address"}, state[:dropoff_address]<>", Tartu, Estonia")
    end
    {:ok, state |> Map.put(:user_session, user_session)}
  end

  when_ ~r/^I summit the booking request$/, fn state ->
    in_browser_session state[:user_session], fn ->
      # Submit the request as usual
      click({:id, "summit-booking"})
      # IO.inspect "transport is booked!"
    end
    {:ok, state}
  end

  and_ ~r/^"(?<taxi_username>[^"]+)" is contacted$/,
  fn state, %{taxi_username: taxi_username} ->
    # 1. Insert a new user in the database for this taxi driver
    # 2. Log in the application with the taxi driver credentials
    # -- Note that we are switching to a browser session for this taxi driver!
    in_browser_session String.to_atom(taxi_username), fn ->
      navigate_to "/#/login"
      fill_field({:id, "username"}, taxi_username)
      fill_field({:id, "password"}, "parool")
      click({:id, "login-btn"})

      # IO.inspect "taxi logged in!"

    end
    {:ok, state |> Map.put(:taxi_username, taxi_username)}
  end

  and_ ~r/^"(?<taxi_username>[^"]+)" decides to "(?<decision>[^"]+)"$/,
  fn state, %{taxi_username: taxi_username, decision: decision} ->
    in_browser_session String.to_atom(taxi_username), fn ->
      # navigate_to "/#/login"
      case decision do
        "reject" ->
          click({:id, "rejectbtn"})
          Process.sleep(3000)
        "accept" ->
          click({:id, "acceptbtn"})
          Process.sleep(3000)
        _ -> Process.sleep(3000)
      end
    end
    {:ok, state}
  end

  then_ ~r/^I should be notified "(?<notification>[^"]+)"$/,
  fn state, %{notification: notification} ->
    in_browser_session state[:user_session], fn ->
      # Process.sleep(3000)
      assert visible_in_page? Regex.compile!(notification)
    end
    {:ok, state}
  end

  scenario_timeouts fn _feature, _scenario ->
   300_000
  end
end
