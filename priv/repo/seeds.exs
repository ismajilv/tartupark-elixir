alias Tartupark.{Repo, User}

[%{name: "Fred Flinstone", username: "fred", password: "parool", role: "customer"},
 %{name: "Barney Rubble", username: "barney", password: "parool", role: "customer"},
 %{name: "Bilbo Baggins", username: "bilbo", password: "parool", role: "driver"},
 %{name: "Frodo Baggins", username: "frodo", password: "parool", role: "driver"}]
|> Enum.map(fn data -> User.changeset(%User{}, data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)