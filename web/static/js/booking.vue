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
  <div id="map" style="width:100%;height:300px; margin-top:10px"></div>
</div>
</template>

<script>
import axios from "axios";
import socket from "./socket";
import auth from "./auth";

export default {
    data: function() {
        return {
            parking_address: "",
            message: ""
        }
    },
    methods: {
        submit: function() {
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
          this.geocoder = new google.maps.Geocoder;
          this.geocoder.geocode({address:this.parking_address}, (results, status)=>{
            if (status == 'OK') {
              var lngLat = {
                lng: results[0].geometry.location.lng(),
                lat: results[0].geometry.location.lat()
              }
              axios.post("/api/search",
                  {lngLat: lngLat},
                  {headers: auth.getAuthHeader()})
                  .then(response => {
                      var locations = response.data;
                      var map = new google.maps.Map(document.getElementById('map'), {
                          zoom: 14,
                          center: lngLat,
                          mapTypeId: google.maps.MapTypeId.ROADMAP
                      });
                      // console.log(locations);
                      locations.map(function(area){
                        if(area.shape == "line"){
                          var flightPath = new google.maps.Polyline({
                            path: area.area,
                            geodesic: true,
                            strokeColor: '#FF0000',
                            strokeOpacity: 0.5,
                            strokeWeight: 6
                          });
                        }else{
                          let polynomCoords = area.area;
                          polynomCoords.push(polynomCoords[0]);
                          // console.log(polynomCoords);
                          var flightPath = new google.maps.Polygon({
                            paths: polynomCoords,
                            strokeColor: '#FF0000',
                            strokeOpacity: 0.8,
                            strokeWeight: 2,
                            fillColor: '#FF0000',
                            fillOpacity: 0.35
                          });
                        }
                        flightPath.setMap(map);
                      })

                  }).catch(error => {
                      console.log(error);
                  });
                }else {
                  alert('Geocode was not successful for the following reason: ' + status);
                }
              }); // end of geocode
        }
    },
    mounted: function() {

        navigator.geolocation.getCurrentPosition(position => {
          console.log(position);
          let loc = {lat: position.coords.latitude, lng: position.coords.longitude};
          this.geocoder = new google.maps.Geocoder;
          this.geocoder.geocode({location: loc}, (results, status) => {
              if (status === "OK" && results[0]){
                this.parking_address = results[0].formatted_address;
              }else {
                alert('Geocode was not successful for the following reason: ' + status);
              }
            });
          this.map = new google.maps.Map(document.getElementById('map'), {zoom: 14, center: loc});
          new google.maps.Marker({position: loc, map: this.map, title: "Parking address"});
        });

        // var channel = socket.channel("customer:lobby", {});
        // channel.join()
        //     .receive("ok", resp => { console.log("Joined successfully", resp) })
        //     .receive("error", resp => { console.log("Unable to join", resp) });

        // channel.on("requests", payload => {
        //     this.message += "\n" + payload.msg;
        //     console.log(this.message);
        // });
    }
}
</script>
