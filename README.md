
#### DATABASE TABLES ####

~~ Places ~~

:latitude,  :float
:longitude, :float
:capacity,  :integer
:status,    :string, default: "available"
:zone_id,    references(:zones)


~~ Zones ~~

:name, 			:string  
:costHourly,    :float
:costRealTime,  :float
:busFree, 		:boolean, default: false
:motoFree, 		:boolean, default: false


~~ Booking ~~

:startDateTime, :naive_datetime
:endDateTime,   :naive_datetime
:place_id, 		references(:places)
:user_id, 		references(:users)



~~ User ~~

:username, 	     	 :string
:encrypted_password, :string
:email, 	     	     :string


~~ Payment ~~

:type, 	     :string (realTime | Hourly)
:cost, 	     :float
:status,     :string, default: "dept"
:booking_id, references(:bookings)




DateTime cast
https://hexdocs.pm/ecto/Ecto.DateTime.html#cast/1
