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

[%{fullName: "Soltan Garayev", username: "soltankara", password: "parool", email: "soltankara@gmail.com", license_number: "111SSS000"},
 %{username: "eldar", password: "parool", fullName: "Eldar Hasanov", email: "email@example.com", license_number: "AAASSSDDD2233"}]
|> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)


# field :point, Geo.Polygon
# field :capacity, :integer
# field :status, :string, default: "available"
# belongs_to :zone, Tartupark.Zone
[%{capacity: 100, zone_tag: "ZB", shape: "polygon", area: %Geo.MultiPoint{coordinates: [{26.718892, 58.384039}, {26.719535, 58.384194}, {26.720025, 58.383635}, {26.719102, 58.383500}], srid: 4326}},
%{capacity: 50, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.721306, 58.383761}, {26.721508, 58.383485}, {26.721539, 58.383325}], srid: 4326}},
%{capacity: 50, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.735556, 58.373967}, {26.735180, 58.373845}, {26.734587, 58.373652}], srid: 4326}},
%{capacity: 50, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.734561, 58.373629}, {26.734176, 58.373524}, {26.733689, 58.373375}], srid: 4326}},
%{capacity: 50, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.733630, 58.373356}, {26.733139, 58.373172}, {26.732578, 58.372985}], srid: 4326}},
%{capacity: 40, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.732507, 58.372943}, {26.731764, 58.372722}], srid: 4326}},
%{capacity: 70, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.733657, 58.373372}, {26.731286, 58.374812}, {26.731281, 58.374832}, {26.730846, 58.375054}], srid: 4326}},
%{capacity: 50, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.730862, 58.375062}, {26.728807, 58.376241}], srid: 4326}},
%{capacity: 40, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.731355, 58.374836}, {26.732372, 58.375204}, {26.732227, 58.375674}, {26.732468, 58.375733}], srid: 4326}},
%{capacity: 40, zone_tag: "ZB", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.734265, 58.375252}, {26.735515, 58.375356}, {26.735349, 58.375483}, {26.734121, 58.375368}], srid: 4326}},
%{capacity: 50, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.731712, 58.372715}, {26.730730, 58.373483}], srid: 4326}},
%{capacity: 40, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.730703, 58.373497}, {26.729539, 58.374428}], srid: 4326}},
%{capacity: 30, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.729544, 58.374481}, {26.730815, 58.375030}], srid: 4326}},
%{capacity: 40, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.729453, 58.374500}, {26.728461, 58.375240}], srid: 4326}},
%{capacity: 20, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.732102, 58.376339}, {26.733188, 58.376846}], srid: 4326}}, ###
%{capacity: 15, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.733161, 58.376899}, {26.731761, 58.377667}], srid: 4326}},
%{capacity: 40, zone_tag: "ZB", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.734265, 58.375252}, {26.735515, 58.375356}, {26.735349, 58.375483}, {26.734121, 58.375368}], srid: 4326}},
%{capacity: 40, zone_tag: "ZB", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.732335, 58.377979}, {26.732984, 58.378252}, {26.733182, 58.378170}, {26.732544, 58.377858}], srid: 4326}},
%{capacity: 70, zone_tag: "ZB", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.733558, 58.378069}, {26.734068, 58.378331}, {26.734411, 58.378320}, {26.734409, 58.378389}, {26.735037, 58.378369}, {26.735053, 58.378158}, {26.735273, 58.378150}, {26.734806, 58.377883}, {26.734329, 58.377728}], srid: 4326}},
%{capacity: 10, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.735118, 58.378383}, {26.736057, 58.378363}], srid: 4326}},
%{capacity: 40, zone_tag: "ZB", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.735226, 58.378484}, {26.735274, 58.378802}, {26.735945, 58.378793}, {26.736111, 58.378464}], srid: 4326}},
%{capacity: 50, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.728353, 58.375220}, {26.726298, 58.374722}], srid: 4326}},
%{capacity: 40, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.726239, 58.374708}, {26.725096, 58.374486}], srid: 4326}},
%{capacity: 20, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.725058, 58.374489}, {26.724312, 58.374683}], srid: 4326}},
%{capacity: 30, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.723256, 58.374232}, {26.725225, 58.373543}], srid: 4326}},
%{capacity: 30, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.725246, 58.373515}, {26.726002, 58.372415}], srid: 4326}},
%{capacity: 30, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.725948, 58.372381}, {26.723449, 58.371959}, {26.722301, 58.372021}], srid: 4326}},
%{capacity: 40, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.722221, 58.372108}, {26.722892, 58.373174}, {26.722962, 58.374111}], srid: 4326}},
%{capacity: 10, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.726057, 58.372358}, {26.726277, 58.372051}], srid: 4326}},
%{capacity: 30, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.726379, 58.372054}, {26.729002, 58.372940}], srid: 4326}},
%{capacity: 40, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.726314, 58.371992}, {26.726754, 58.371356}, {26.727199, 58.370723}], srid: 4326}},
%{capacity: 70, zone_tag: "ZB", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.727317, 58.370734}, {26.728063, 58.371277}, {26.728632, 58.371839}, {26.728981, 58.371949}, {26.729480, 58.372053}, {26.731953, 58.372343}], srid: 4326}},
%{capacity: 15, zone_tag: "ZB", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.722077, 58.370973}, {26.722125, 58.371043}, {26.722699, 58.371001}, {26.722667, 58.370916}], srid: 4326}},
%{capacity: 50, zone_tag: "ZB", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.720312, 58.373006}, {26.720993, 58.372418}, {26.720306, 58.372142}, {26.719625, 58.372702}], srid: 4326}},
%{capacity: 70, zone_tag: "ZB", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.720548, 58.373051}, {26.721090, 58.373307}, {26.721718, 58.372888}, {26.720994, 58.372598}], srid: 4326}},
%{capacity: 10, zone_tag: "BUS", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.736724, 58.375378}, {26.736622, 58.375645}, {26.736230, 58.375563}, {26.736412, 58.375411}], srid: 4326}},
%{capacity: 5, zone_tag: "BUS", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.734577, 58.377014}, {26.735140, 58.376702}], srid: 4326}},
%{capacity: 5, zone_tag: "BUS", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.734952, 58.377245}, {26.735843, 58.376750}], srid: 4326}},
%{capacity: 4, zone_tag: "BUS", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.733349, 58.378530}, {26.732979, 58.378297}], srid: 4326}},
%{capacity: 10, zone_tag: "BUS", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.728980, 58.381087}, {26.729211, 58.380944}, {26.728884, 58.380857}, {26.728707, 58.381040}], srid: 4326}},
%{capacity: 5, zone_tag: "BUS", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.734577, 58.377014}, {26.735140, 58.376702}], srid: 4326}},
%{capacity: 5, zone_tag: "BUS", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.734952, 58.377245}, {26.735843, 58.376750}], srid: 4326}},
%{capacity: 20, zone_tag: "M120", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.733349, 58.378530}, {26.732979, 58.378297}], srid: 4326}}],
%{capacity: 5, zone_tag: "BUS", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.725907, 58.376703}, {26.726041, 58.376633}, {26.725880, 58.376526}, {26.725671, 58.376636}], srid: 4326}}], #RIA ULIKULI
%{capacity: 17, zone_tag: "ZA", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.725968, 58.376729}, {26.724976, 58.377334}], srid: 4326}}], #ULIKOOLI 1
%{capacity: 23, zone_tag: "ZA", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.724854, 58.377416}, {26.723239, 58.378420}], srid: 4326}}], #ULIKOOLI 2
%{capacity: 15, zone_tag: "ZA", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.723174, 58.378488}, {26.722557, 58.379042}], srid: 4326}}], #ULIKOOLI 3
%{capacity: 30, zone_tag: "ZA", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.722509, 58.379090}, {26.722557, 58.379042}, {26.721227, 58.380083}], srid: 4326}}], #ULIKOOLI 4
%{capacity: 10, zone_tag: "ZA", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.720921, 58.380255}, {26.720572, 58.380792}], srid: 4326}}], #ULIKOOLI 5
%{capacity: 20, zone_tag: "ZA", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.720513, 58.380862}, {26.720368, 58.381568}], srid: 4326}}], #ULIKOOLI 6
%{capacity: 20, zone_tag: "ZA", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.720019, 58.381993}, {26.719413, 58.382620}], srid: 4326}}], #JAANI 1
%{capacity: 20, zone_tag: "ZA", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.719333, 58.382679}, {26.718587, 58.383216}], srid: 4326}}], #JAANI 2
%{capacity: 20, zone_tag: "MOTO", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.724941, 58.380584}, {26.724804, 58.380574}, {26.724771, 58.380647}, {26.724886, 58.380648}], srid: 4326}}], #RAEKOJA PLATS
%{capacity: 30, zone_tag: "ZB", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.725192, 58.380887}, {26.725098, 58.381206}, {26.724843, 58.381342}, {26.725023, 58.380871}], srid: 4326}}], #RAEKOJA PLATS
%{capacity: 7, zone_tag: "BUS", shape: "polygon", area:  %Geo.MultiPoint{coordinates: [{26.725219, 58.380886}, {26.725297, 58.380893}, {26.725305, 58.380939}, {26.725216, 58.380980}], srid: 4326}}], #RAEKOJA PLATS
%{capacity: 2, zone_tag: "BUS", shape: "line", area:  %Geo.MultiPoint{coordinates: [{26.722953, 58.385142}, {26.722797, 58.385257}], srid: 4326}}] #EMAJIOE
|> Enum.map(fn place_data -> Ecto.build_assoc(Repo.get_by!(Zone, tag: place_data.zone_tag), :places, place_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)
