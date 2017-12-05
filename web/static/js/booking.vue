<template>
<div>
  <div class="form-group">
    <label class="control-label col-sm-3" for="parking_address">Parking address:</label>
    <div class="col-sm-9">
      <input type="text" class="form-control" id="parking_address" v-model="parking_address">
    </div>
  </div>

  <div class="form-group">
    <label class="control-label col-sm-3" for="parking_start_time" style="margin: 10px auto;">Start Date:</label>
    <div class="col-sm-9">
      <date-picker v-model="parking_start_time" :config="config" id="parking_start_time" style="margin: 10px auto;"></date-picker>
    </div>
  </div>

  <div class="form-group">
    <label class="control-label col-sm-3" for="parking_end_time" style="margin-bottom: 10px;">End Date:</label>
    <div class="col-sm-9">
      <date-picker v-model="parking_end_time" :config="config" id="parking_end_time" style="margin-bottom: 10px;"></date-picker>
    </div>
  </div>

  <div class="form-group">
    <label class="control-label col-sm-3" style="margin-right: 15px;">Payment Type:</label>
    
    <input type="radio" id="hourly" value="Hourly" v-on:click="dateTimeStatusWrite" v-model="parking_type">
    <label for="hourly">Hourly</label>
    <select v-model="h_payment_selected" id="hourly_payment_type">
      <option disabled value="">When will you pay?</option>
      <option>Before Parking</option>
      <option>After Parking</option>
    </select>
    
    <input type="radio" id="realtime" value="Real Time" checked="checked" v-on:click="dateTimeStatusRead" v-model="parking_type">
    <label for="realtime">Real Time</label>
    <select v-model="rt_payment_selected" id="real_time_payment_type">
      <option disabled value="">When will you pay?</option>
      <option>On the Spot</option>
      <option>End of Month</option>
    </select>
  </div>
  
  <div class="form-group">
    <label class="control-label col-sm-3" style="margin-right: 15px;">Search Radius:</label>
    <select v-model="parking_search_radius">
      <option disabled value="">Please select redius</option>
      <option>100 meters</option>
      <option>500 meters</option>
      <option>1000 meters</option>
    </select>
  </div>

  <div class="form-group">
    <div class="col-sm-offset-3 col-sm-9">
      <button class="btn btn-default" v-on:click="search">Search</button>
      <button class="btn btn-default" v-on:click="submit">Submit</button>
    </div>
  </div>
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
            parking_type: "Real Time",
            parking_start_time: new Date(),
            parking_end_time: new Date(),
            parking_search_radius: '100 meters',
            h_payment_selected: "Before Parking",
            rt_payment_selected: "On the Spot",
            config: {
              format: 'DD/MM/YYYY H:m:s',
              useCurrent: false,
              showClear: true,
              showClose: true,
            }
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
        dateTimeStatusRead: function(){
          document.getElementById("parking_start_time").readOnly = true;
          document.getElementById("parking_end_time").readOnly = true;
          document.getElementById("hourly_payment_type").style.visibility = "hidden";
          document.getElementById("real_time_payment_type").style.visibility = "visible";
        },
        dateTimeStatusWrite: function(){
          document.getElementById("parking_start_time").readOnly = false;
          document.getElementById("parking_end_time").readOnly = false;
          document.getElementById("hourly_payment_type").style.visibility = "visible";
          document.getElementById("real_time_payment_type").style.visibility = "hidden";
        },
        search: function() {
          this.geocoder = new google.maps.Geocoder;
          this.geocoder.geocode({address:this.parking_address}, (results, status)=>{
            if (status == 'OK') {
              var lngLat = {
                lng: results[0].geometry.location.lng(),
                lat: results[0].geometry.location.lat()
              }

              if (this.picked == "Real Time"){
                var s_date = null;
                var e_date = null;
                var hps = null;
                var rtps = this.rt_payment_selected;
                var p_type = this.rt_payment_selected;
              } else {
                var s_date = this.parking_start_time;
                var e_date = this.parking_end_time;
                var hps = this.h_payment_selected;
                var rtps = null;
                var p_type = this.h_payment_selected;
              }

              // console.log("parking address: " + this.parking_address +" - startdate: "+ s_date + 
              //             " - enddate: " + e_date + " - parking_type: " + this.parking_type + 
              //             " - selected: " + this.parking_search_radius + 
              //             " - hps: " + hps + " - rtps: " + rtps);
              console.log("parking type: "+p_type);

              axios.post("/api/search",
                  { lngLat: lngLat, 
                    parkingStartTime: s_date,
                    parkingEndTime: e_date,
                    parkingSearchRadius: this.parking_search_radius,
                    parkingType: p_type
                    // ,
                    // hourlyPaymentType: hps,
                    // realTimePaymentType: rtps
                    },
                  {headers: auth.getAuthHeader()})
                  .then(response => {
                      var locations = response.data;
                      var map = new google.maps.Map(document.getElementById('map'), {
                          zoom: 14,
                          center: lngLat,
                          mapTypeId: google.maps.MapTypeId.ROADMAP
                      });
                      console.log(locations);
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

        if (this.parking_type == "Real Time"){
          document.getElementById("parking_start_time").readOnly = true;
          document.getElementById("parking_end_time").readOnly = true;
          document.getElementById("hourly_payment_type").style.visibility = "hidden";
          document.getElementById("real_time_payment_type").style.visibility = "visible";
        } else {
          document.getElementById("parking_start_time").readOnly = false;
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
