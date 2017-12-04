alias Tartupark.{Repo, Zone, Place}

[%{name: "Zone A", tag: "A", costHourly: 2.0, costRealTime: 0.16, busFree: false, motoFree: false, freeTimeLimit: 15},
%{name: "Zone B", tag: "B", costHourly: 1.0, costRealTime: 0.08, busFree: false, motoFree: false, freeTimeLimit: 90},
%{name: "Free Zone", tag: "Free", costHourly: 0.0, costRealTime: 0.0, busFree: true, motoFree: true, freeTimeLimit: -1},
%{name: "Building car park 60 min", tag: "60", costHourly: 0.0, costRealTime: 0.0, busFree: true, motoFree: true, freeTimeLimit: 60},
%{name: "Building car park 120 min",tag: "120", costHourly: 0.0, costRealTime: 0.0, busFree: true, motoFree: true, freeTimeLimit: 120},
%{name: "Free park for bus",tag: "bus", costHourly: 0.0, costRealTime: 0.0, busFree: true, motoFree: false, freeTimeLimit: -1},
%{name: "Free park for moto",tag: "moto", costHourly: 0.0, costRealTime: 0.0, busFree: false, motoFree: true, freeTimeLimit: -1}]
|> Enum.map(fn user_data -> Zone.changeset(%Zone{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)


# field :point, Geo.Polygon
# field :capacity, :integer
# field :status, :string, default: "available"
# belongs_to :zone, Tartupark.Zone
[%{capacity: 100, shape: "polygon", area: %Geo.MultiPoint{coordinates: [{26.718892, 58.384039}, {26.719535, 58.384194}, {26.720025, 58.383635}, {26.719102, 58.383500}], srid: 4326}},
%{capacity: 100, shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.721306, 58.383761}, {26.721508, 58.383485}, {26.721539, 58.383325}], srid: 4326}}]
|> Enum.map(fn user_data -> Place.changeset(%Place{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)
