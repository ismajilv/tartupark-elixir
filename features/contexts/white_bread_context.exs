defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers
  alias Tartupark.{Repo, User}

  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
  end

  scenario_starting_state fn state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(Tartupark.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Tartupark.Repo, {:shared, self()})
    %{}
  end
  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Tartupark.Repo)
    Hound.end_session
  end

  given_ ~r/^the following user$/, fn state,
  %{table_data: table} ->
     table
     |> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
     |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
     {:ok, state}
  end

  when_ ~r/^User log in on the app$/, fn state ->
    in_browser_session String.to_atom(to_string(1)), fn ->

      navigate_to "/"
      fill_field({:id, "log-username"}, "ns")
      fill_field({:id, "log-password"}, "parool")
      click({:id, "login-for-test"})

      fill_field({:id, "log-username"}, "ns")
      fill_field({:id, "log-password"}, "parool")
      click({:id, "login-for-test"})

      Process.sleep(1000)
    end
    {:ok, state}
    end

    then_ ~r/^User enter the parking address of "(?<destinations>[^"]+)", "(?<payment_type>[^"]+)", "(?<start_date>[^"]+)", "(?<end_date>[^"]+)" and "(?<search_radius>[^"]+)"$/,
    fn state, %{destinations: destinations,payment_type: payment_type,start_date: start_date,end_date: end_date,search_radius: search_radius} ->
      in_browser_session String.to_atom(to_string(1)), fn ->
        click({:id, "btn_map"})
        fill_field({:id, "parking_address"}, to_string(destinations) <> ", Tartu, Estonia")
        Process.sleep(10000)
        #fill_field({:id, parking_start_time}, "")
      end
      {:ok, state}
    end

    and_ ~r/^User press choose$/, fn state ->
      {:ok, state}
    end
end
