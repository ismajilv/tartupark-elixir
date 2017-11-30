alias Tartupark.{Repo, User}

[%{fullName: "Freddi Murcery", username: "fred", password: "parool", email: "customer@example.com"},
 %{fullName: "Billy Jones", username: "bilbo", password: "parool", email: "taxi-driver@example.com"}]
|> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)
