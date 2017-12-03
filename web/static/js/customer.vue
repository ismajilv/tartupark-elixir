<template>
<div>
  <div class="form-group">
    <label class="control-label col-sm-3" for="parking_address">Parking address:</label>
    <div class="col-sm-9">
      <input type="text" class="form-control" id="parking_address" v-model="parking_address">
    </div>
  </div>
  <div class="form-group">
    <div class="col-sm-offset-3 col-sm-9">
      <button class="btn btn-default" v-on:click="search">Search</button>
      <button class="btn btn-default" v-on:click="submit">Submit</button>
    </div>
  </div>
  <div><textarea readonly class="col-sm-12" style="background-color:#f4f7ff" rows="4" v-model="message"></textarea></div>
  <div id="map" style="width:100%;height:300px"></div>
</div>
</template>

<script>
import axios from "axios";
import socket from "./socket";
import auth from "./auth";

export default {
    data: function() {
        return {
            parking_address: "Liivi 2, Tartu, Estonia"
        }
    },
    methods: {
        submit: function() {
            console.log(auth.getAuthHeader());
            axios.post("/api/bookings",
                {parking_address: this.parking_address},
                {headers: auth.getAuthHeader()})
                .then(response => {
                    console.log(response);
                })
                .catch(error => {
                    console.log(error);
                });
        },
        search: function() {
            axios.post("/api/search",
                {parking_address: this.parking_address},
                {headers: auth.getAuthHeader()})
                .then(response => {
                    // console.log(response.data.loc[0]);
                    var locations = response.data.loc;
                    console.log(locations);
                    var map = new google.maps.Map(document.getElementById('map'), {
                        zoom: 13,
                        center: new google.maps.LatLng(58.3791179,26.7241151),
                        mapTypeId: google.maps.MapTypeId.ROADMAP
                    });

                    var infowindow = new google.maps.InfoWindow();
                    var marker, i;

                    for (i = 0; i < locations.length; i++) {  
                        marker = new google.maps.Marker({
                            position: new google.maps.LatLng(locations[i][1], locations[i][2]),
                            map: map
                        });

                        google.maps.event.addListener(marker, 'click', (function(marker, i) {
                            return function() {
                                infowindow.setContent(locations[i][0]);
                                infowindow.open(map, marker);
                            }})
                        (marker, i));
                    }

                    this.message = response.data.msg;
                }).catch(error => {
                    console.log(error);
                });
        }
    },
    mounted: function() {

        // var locations = [
        //     ['Tartu Ülikool', 58.3816146,26.716936,15],
        //     ['Fortumo OÜ', 58.3791179,26.7241151],
        //     ['Shooters Tartu', 58.3717589,26.7024541]
        // ];

        // var map = new google.maps.Map(document.getElementById('map'), {
        //     zoom: 13,
        //     center: new google.maps.LatLng(58.3791179,26.7241151),
        //     mapTypeId: google.maps.MapTypeId.ROADMAP
        // });

        // var infowindow = new google.maps.InfoWindow();
        // var marker, i;

        // for (i = 0; i < locations.length; i++) {  
        //     marker = new google.maps.Marker({
        //         position: new google.maps.LatLng(locations[i][1], locations[i][2]),
        //         map: map
        // });

        // google.maps.event.addListener(marker, 'click', (function(marker, i) {
        //     return function() {
        //         infowindow.setContent(locations[i][0]);
        //         infowindow.open(map, marker);
        //     }})(marker, i));
        // }
        
        navigator.geolocation.getCurrentPosition(position => {
          let loc = {lat: position.coords.latitude, lng: position.coords.longitude};
          this.geocoder = new google.maps.Geocoder;
          this.geocoder.geocode({location: loc}, (results, status) => {
            //   if (status === "OK" && results[0])
            //     this.pickup_address = results[0].formatted_address;
            });
          this.map = new google.maps.Map(document.getElementById('map'), {zoom: 14, center: loc});
          new google.maps.Marker({position: loc, map: this.map, title: "Parking address"});
        });
        
        var channel = socket.channel("customer:lobby", {});
        channel.join()
            .receive("ok", resp => { console.log("Joined successfully", resp) })
            .receive("error", resp => { console.log("Unable to join", resp) });

        channel.on("requests", payload => {
            this.message += "\n" + payload.msg;
            console.log(this.message);
        });
    }
}
</script>
