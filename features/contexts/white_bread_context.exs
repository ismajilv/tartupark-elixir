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

  given_ ~r/^the following person, user register on the STRS Customer app$/, fn state,
  %{table_data: table} ->
    table
    |> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}
  end

  when_ ~r/^I enter the booking information on the STRS Customer app$/, fn state ->
    session = to_string(Enum.random(0..100000))

    in_browser_session String.to_atom(session), fn ->
      navigate_to "/#/login"

      fill_field({:id, "log-username"}, "username")
      fill_field({:id, "log-password"}, "parool")

      click({:id, "login-for-test"})

      Process.sleep(30000)
    end
    {:ok, state}
  end

  then_ ~r/^I press the registration button$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I fill the registration page with my details and submit$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^The web page is directed to Main page$/, fn state ->
    {:ok, state}
  end

  when_ ~r/^I enter the parlking address of "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  then_ ~r/^I specify payment type of ""$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I specify start date of ""$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I specify start date of "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  and_ ~r/^I spesify search radius of "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  and_ ~r/^I want to park my car in "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  and_ ~r/^I press choose$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I get notification of "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  when_ ~r/^Payment method is Hourly and payment time is Before Parking$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I add credit card details$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I submit payment$/, fn state ->
    {:ok, state}
  end

  when_ ~r/^Payment method is Hourly and payment time is End of month$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I redirected to main page$/, fn state ->
    {:ok, state}
  end

  when_ ~r/^Payment method is Real time and payment time is Before Parking$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I directed to main page$/, fn state ->
    {:ok, state}
  end
end
