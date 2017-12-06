<template>
<div>
  <div class="form-group">
    <div class="row">
      <label class="control-label col-sm-3" for="parking_address">Parking address:</label>
      <div class="col-sm-9">
        <input type="text" class="form-control" id="parking_address" v-model="parking_address" required>
      </div>
    </div>

    <div class="row">
      <label class="control-label col-sm-3" for="parking_start_time" style="margin: 10px auto;">Start Date:</label>
      <div class="col-sm-9">
        <date-picker v-model="parking_start_time" :config="config" id="parking_start_time" style="margin: 10px auto;"></date-picker>
      </div>
    </div>

    <div class="row">
      <label class="control-label col-sm-3" for="parking_end_time" style="margin-bottom: 10px;">End Date:</label>
      <div class="col-sm-9">
        <date-picker v-model="parking_end_time" :config="config" id="parking_end_time" style="margin-bottom: 10px;"></date-picker>
      </div>
    </div>

    <div class="row">
      <label class="control-label col-sm-3" style="margin-right: 15px;">Payment Type:</label>

      <input type="radio" id="hourly" value="Hourly" v-on:click="dateTimeStatusWrite" v-model="payment_type">
      <label for="hourly">Hourly</label>
      <select v-model="h_payment_selected" id="hourly_payment_type">
        <option disabled value="">When will you pay?</option>
        <option>Before Parking</option>
        <option>After Parking</option>
      </select>

      <input type="radio" id="realtime" value="Real Time" checked="checked" v-on:click="dateTimeStatusRead" v-model="payment_type">
      <label for="realtime">Real Time</label>
      <select v-model="rt_payment_selected" id="real_time_payment_type">
        <option disabled value="">When will you pay?</option>
        <option>After Parking</option>
        <option>End of Month</option>
      </select>
    </div>

    <div class="row">
      <label class="control-label col-sm-3" style="margin-right: 15px;">Search Radius:</label>
      <select v-model="parking_search_radius">
        <option disabled value="">Please select redius</option>
        <option>100 meters</option>
        <option>500 meters</option>
        <option>1000 meters</option>
      </select>
    </div>

    <div class="row">
      <div class="col-sm-offset-3 col-sm-9">
        <button type="submit" class="btn btn-default" v-on:click="search">Search</button>
        <button type="submit" class="btn btn-default" v-on:click="submit" v-if="(searchingResults != null) && (searchingResults.length == 1)">Submit</button>
      </div>
    </div>
  </div> <!--  end of form-group -->
  <div id="map" style="width:100%;height:300px; margin-top:75px"></div>
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
            message: "",
            payment_type: "Real Time",
            parking_start_time: new Date(),
            parking_end_time: new Date(),
            parking_search_radius: '100 meters',
            h_payment_selected: "Before Parking",
            rt_payment_selected: "End of Month",
            config: {
              format: 'DD/MM/YYYY H:m:s',
              useCurrent: false,
              showClear: true,
              showClose: true,
            },
            searchingResults: null
        }
    },
    methods: {
        submit: function() {
          if(this.searchingResults != null){
            axios.post("/api/bookings",
                {parking_address: this.searchingResults},
                {headers: auth.getAuthHeader()})
                .then(response => {
                    console.log(response);
                })
                .catch(error => {
                    console.log(error);
                });
            }
        },
        dateTimeStatusRead: function(){
          // document.getElementById("parking_start_time").readOnly = true;
          document.getElementById("parking_end_time").readOnly = true;
          document.getElementById("hourly_payment_type").style.visibility = "hidden";
          document.getElementById("real_time_payment_type").style.visibility = "visible";
        },
        dateTimeStatusWrite: function(){
          // document.getElementById("parking_start_time").readOnly = false;
          document.getElementById("parking_end_time").readOnly = false;
          document.getElementById("hourly_payment_type").style.visibility = "visible";
          document.getElementById("real_time_payment_type").style.visibility = "hidden";
        },
        search: function() {
          this.searchingResults = null;
          this.geocoder = new google.maps.Geocoder;
          this.geocoder.geocode({address:this.parking_address}, (results, status)=>{
            if (status == 'OK') {
              var lngLat = {
                lng: results[0].geometry.location.lng(),
                lat: results[0].geometry.location.lat()
              }

              if (this.payment_type == "Real Time"){
                var parkingStartTime = this.parking_start_time;
                var parkingEndTime = null;
                var hourlyPaymentStatus = null;
                var realTimePaymentStatus = this.rt_payment_selected;
                var paymentTime = this.rt_payment_selected;
              } else {
                var parkingStartTime = this.parking_start_time;
                var parkingEndTime = this.parking_end_time;
                var hourlyPaymentStatus = this.h_payment_selected;
                var realTimePaymentStatus = null;
                var paymentTime = this.h_payment_selected;
              }

              axios.post("/api/search",
                  { lngLat: lngLat,
                    parkingStartTime: parkingStartTime,
                    parkingEndTime: parkingEndTime,
                    parkingSearchRadius: this.parking_search_radius,
                    paymentTime: paymentTime,
                    paymentType: this.payment_type
                    // ,
                    // hourlyPaymentType: hourlyPaymentStatus,
                    // realTimePaymentType: realTimePaymentStatus
                    },
                  {headers: auth.getAuthHeader()})
                  .then(response => {
                      var searchingResults = response.data;
                      this.searchingResults = [searchingResults[0]];
                      // console.log("search1: " + searchingResults);
                      // console.log("search2: " + searchingResults[0].zone.costHourly);
                      var map = new google.maps.Map(document.getElementById('map'), {
                          zoom: 14,
                          center: lngLat,
                          mapTypeId: google.maps.MapTypeId.ROADMAP
                      });
                      var coordsForMarker = [];

                      var zoneA = "Zone A";
                      var zoneB = "Zone B";
                      var freeZone = "Free zone";
                      var Building60 = "Building parking spot for 60 min";
                      var Building120 = "Building parking spot for 120 min";
                      var FreeForBus = "Free parking spot for buses";
                      var FreeForMotorAndMoped = "Free parking spot for motocycles and mopeds";

                      for(var j = 0; j < searchingResults.length; j++){
                        for(var i = 0; i < searchingResults[j].area.length; i++){
                          var coord = [i+j, searchingResults[j].area[i].lat, searchingResults[j].area[i].lng,
                                        searchingResults[j].zone.costHourly,
                                        searchingResults[j].zone.costRealTime,
                                        searchingResults[j].zone.description,
                                        searchingResults[j].zone.freeTimeLimit,
                                        searchingResults[j].parkingStartTime,
                                        searchingResults[j].parkingEndTime,
                                        searchingResults[j].paymentTime,
                                        searchingResults[j].paymentType,
                                        searchingResults[j].shape];
                        }
                        coordsForMarker[j] = coord;
                      }

                      for(var j = 0; j < searchingResults.length; j++){

                        var color = "#FF0000";
                        var shape = searchingResults[j].shape;

                        var flightPlanCoordinates = [];
                        for(var x = 0; x < searchingResults[j].area.length; x++){
                            var coortinates = {lat: searchingResults[j].area[x].lat, lng: searchingResults[j].area[x].lng}
                            flightPlanCoordinates[x] = coortinates;
                        }

                        if(coordsForMarker[j][5] == zoneB){
                          color = "#4286f4";
                        } else if(coordsForMarker[j][5] == freeZone){
                          color = "#92a06b";
                        } else if(coordsForMarker[j][5] == Building60){
                          color = "#ff810c";
                        } else if(coordsForMarker[j][5] == Building120){
                          color = "#b50594";
                        } else if(coordsForMarker[j][5] == FreeForBus){
                          color = "#100b7c";
                        } else if(coordsForMarker[j][5] == FreeForMotorAndMoped){
                          color = "#3b3799";
                        }

                        if(shape == "polygon"){
                           var flightPath = new google.maps.Polygon({
                              paths: flightPlanCoordinates,
                              strokeColor: color,
                              strokeOpacity: 0.8,
                              strokeWeight: 2,
                              fillColor: color,
                              fillOpacity: 0.35
                          });
                        } else{
                          var flightPath = new google.maps.Polyline({
                            path: flightPlanCoordinates,
                            geodesic: true,
                            strokeColor: color,
                            strokeOpacity: 1.0,
                            strokeWeight: 6
                          });
                        }

                        flightPath.setMap(map);
                      }

                      var marker;
                      for (var i = 0; i < coordsForMarker.length; i++) {
                        marker = new google.maps.Marker({
                          position: new google.maps.LatLng(coordsForMarker[i][1], coordsForMarker[i][2]),
                          map: map
                        });

                        var infowindow = new google.maps.InfoWindow({});

                        google.maps.event.addListener(marker, 'click', (function(marker, i) {

                          var contenString = "Hourly payment is " + coordsForMarker[i][3] +   ". Euro <br>" +
                                              "Real Time payment is " + coordsForMarker[i][4] +  ". Euro <br>" +
                                              "Descrtiption: This parking belongs to " + coordsForMarker[i][5] +    ". <br>" +
                                              "Free time limit is " + coordsForMarker[i][6] +    ". <br>" +
                                              // "Parking starts at " + coordsForMarker[i][7] +    "<br>" +
                                              // "Parking ends at " + coordsForMarker[i][8] +    "<br>" +
                                              "Payment time is " + coordsForMarker[i][9] +    ". <br>" +
                                              "Payment type is " + coordsForMarker[i][10] + ". <br>" +
                                              "<button type='submit' class='btn btn-default'>Choose</button>"

                          return function() {
                            infowindow.setContent(contenString);
                            infowindow.open(map, marker);
                          }
                        })(marker, i));
                      }

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

        if (this.payment_type == "Real Time"){
          // document.getElementById("parking_start_time").readOnly = true;
          document.getElementById("parking_end_time").readOnly = true;
          document.getElementById("hourly_payment_type").style.visibility = "hidden";
          document.getElementById("real_time_payment_type").style.visibility = "visible";
        } else {
          // document.getElementById("parking_start_time").readOnly = false;
          document.getElementById("parking_end_time").readOnly = false;
          document.getElementById("hourly_payment_type").style.visibility = "visible";
          document.getElementById("real_time_payment_type").style.visibility = "hidden";
        }

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
