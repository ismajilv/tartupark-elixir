alias Tartupark.{Repo, Zone, Place, User}

[%{description: "Zone A", tag: "ZA", costHourly: 2.0, costRealTime: 0.16, freeTimeLimit: 15},
%{description: "Zone B", tag: "ZB", costHourly: 1.0, costRealTime: 0.08, freeTimeLimit: 90},
%{description: "Free zone", tag: "FREE", costHourly: 0.0, costRealTime: 0.0, freeTimeLimit: -1},
%{description: "Building parking spot for 60 min", tag: "M60", costHourly: 0.0, costRealTime: 0.0, freeTimeLimit: 60},
%{description: "Building parking spot for 120 min", tag: "M120", costHourly: 0.0, costRealTime: 0.0, freeTimeLimit: 120},
%{description: "Free parking spot for buses", tag: "BUS", costHourly: 0.0, costRealTime: 0.0, freeTimeLimit: -1},
%{description: "Free parking spot for motocycles and mopeds", tag: "MOTO", costHourly: 0.0, costRealTime: 0.0, freeTimeLimit: -1}]
|> Enum.map(fn zone_data -> Zone.changeset(%Zone{}, zone_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)

[%{fullName: "Soltan Garayev", username: "soltankara", password: "parool", email: "soltankara@gmail.com", license_number: "111SSS000"}]
|> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)


# field :point, Geo.Polygon
# field :capacity, :integer
# field :status, :string, default: "available"
# belongs_to :zone, Tartupark.Zone
[%{capacity: 100, zone_tag: "ZA", shape: "polygon", area: %Geo.MultiPoint{coordinates: [{26.718892, 58.384039}, {26.719535, 58.384194}, {26.720025, 58.383635}, {26.719102, 58.383500}], srid: 4326}},
%{capacity: 100, zone_tag: "ZA", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.721306, 58.383761}, {26.721508, 58.383485}, {26.721539, 58.383325}], srid: 4326}}]
|> Enum.map(fn place_data -> Ecto.build_assoc(Repo.get_by!(Zone, tag: place_data.zone_tag), :places, place_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)
