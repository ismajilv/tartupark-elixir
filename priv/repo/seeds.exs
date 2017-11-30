alias Tartupark.{Repo, Zone}

[%{name: "Zone A", tag: "A", costHourly: 2.0, costRealTime: 0.16, busFree: false, motoFree: false, freeTimeLimit: 15},
%{name: "Zone B", tag: "B", costHourly: 1.0, costRealTime: 0.08, busFree: false, motoFree: false, freeTimeLimit: 90},
%{name: "Free Zone", tag: "Free", costHourly: 0.0, costRealTime: 0.0, busFree: true, motoFree: true, freeTimeLimit: -1},
%{name: "Building car park 60 min", tag: "60", costHourly: 0.0, costRealTime: 0.0, busFree: true, motoFree: true, freeTimeLimit: 60},
%{name: "Building car park 120 min",tag: "120", costHourly: 0.0, costRealTime: 0.0, busFree: true, motoFree: true, freeTimeLimit: 120},
%{name: "Free park for bus",tag: "bus", costHourly: 0.0, costRealTime: 0.0, busFree: true, motoFree: false, freeTimeLimit: -1},
%{name: "Free park for moto",tag: "moto", costHourly: 0.0, costRealTime: 0.0, busFree: false, motoFree: true, freeTimeLimit: -1}]
|> Enum.map(fn user_data -> Zone.changeset(%Zone{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)



