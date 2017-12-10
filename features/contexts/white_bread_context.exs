defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers
  alias Tartupark.{Repo}

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

  given_ ~r/^the following parking spaces$/, fn state ->
    {:ok, state}
  end

  when_ ~r/^I enter my destination of "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  and_ ~r/^I want to park my car in "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  and_ ~r/^I want my parking time start in "(?<argument_one>[^"]+)" and last until "(?<argument_two>[^"]+)"$/,
  fn state, %{argument_one: _argument_one,argument_two: _argument_two} ->
    {:ok, state}
  end

  and_ ~r/^I enter the parking information on the STRS Customer app$/, fn state ->
    {:ok, state}
  end

  when_ ~r/^I summit the parking request$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I should be notified "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end
end
