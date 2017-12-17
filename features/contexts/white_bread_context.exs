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
    in_browser_session String.to_atom(to_string(Enum.random(0..100000))), fn ->

      navigate_to "/"
      fill_field({:id, "log-username"}, "ns")
      fill_field({:id, "log-password"}, "parool")
      click({:id, "login-for-test"})

      fill_field({:id, "log-username"}, "ns")
      fill_field({:id, "log-password"}, "parool")
      click({:id, "login-for-test"})

      Process.sleep(30000)
    end
    {:ok, state}
  end

  then_ ~r/^User enter the parking address of "(?<destinations>[^"]+)"$/,
  fn state, %{destinations: destinations} ->
    fill
    {:ok, state}
  end

  and_ ~r/^User specify payment type of "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  and_ ~r/^User specify start date of "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  and_ ~r/^User spesify search radius of "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  and_ ~r/^User want to park his car in "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  and_ ~r/^User press choose$/, fn state ->
    {:ok, state}
  end
end
