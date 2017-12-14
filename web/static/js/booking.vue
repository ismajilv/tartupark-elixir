<template>
<div>
  <div class="form-group" style="width: 90%;">
    <div class="row">
      <label class="control-label col-sm-3" for="parking_address" style="margin: 10px auto;">Parking address:</label>
      <div class="col-sm-9">
        <input type="text" class="form-control" id="parking_address" style="margin: 10px auto;" v-model="parking_address" required>
      </div>
    </div>

    <div class="row">
      <label class="control-label col-sm-3" for="parking_start_time" style="margin: 10px auto;">Start Date:</label>
      <div class="col-sm-9">
        <date-picker v-model="parking_start_time" :config="config" id="parking_start_time" style="margin: 10px auto;"></date-picker>
      </div>
    </div>

    <div class="row">
      <label class="control-label col-sm-3" for="parking_end_time" style="margin: 10px auto;">End Date:</label>
      <div class="col-sm-9">
        <date-picker v-model="parking_end_time" :config="config" id="parking_end_time" style="margin: 10px auto;"></date-picker>
      </div>
    </div>

    <div class="row">
      <label class="control-label col-sm-3" style="margin: 10px auto; margin-right: 10px;">Payment Type:</label>

      <input type="radio" id="hourly" value="Hourly" v-on:click="dateTimeStatusWrite" style="margin: 20px auto;"v-model="payment_type">
      <label for="hourly">Hourly</label>

      <input type="radio" id="realtime" value="Real Time" checked="checked" v-on:click="dateTimeStatusRead" v-model="payment_type">
      <label for="realtime">Real Time</label>

      <select v-model="payment_selected" id="payment_type">
        <option disabled value="">When will you pay?</option>
        <option>Before Parking</option>
        <option>End of Month</option>
      </select>
    </div>

    <div class="row">
      <label class="control-label col-sm-3" style="margin: 10px auto; margin-right: 15px;">Search Radius:</label>
      <select v-model="parking_search_radius" style="margin: 10px auto; margin-right: 15px;">
        <option disabled value="">Please select redius</option>
        <option>100 meters</option>
        <option>500 meters</option>
        <option>1000 meters</option>
      </select>
    </div>

    <div class="row">
      <div class="col-sm-offset-3 col-sm-9">
        <button type="submit" class="btn btn-default" id="btn_search" v-on:click="search">Search</button>
        <router-link class="btn btn-default" :to="{ name: 'summary'}">Go</router-link>
        <button class="btn btn-default" @click="showModal=true" style="display: none;" id="btn_submit">Submit</button>
        <button type="submit" class="btn btn-default" id="btn_submit2" style="display: none;" v-on:click="submit">Submit</button>
      </div>
    </div>
  </div> <!--  end of form-group -->
<div id="map" style="width:90%;height:500px; margin: 0 auto; margin-top:25px"></div>

  <my-modal v-show="showModal" @close="showModal=false">
    <form class="col-md-10 col-md-offset-1" style="padding:0">
        <div class="form-group col-md-12">
            <input type="text" class="form-control" id="cardNumber" v-model="cardNumber" placeholder="Card Number" contenteditable="false">
        </div>
        <p style="text-align:center;">Expiration</p>
        <div class="form-group col-md-6">
            <input type="text" class="form-control" id="cardMonth" v-model="cardMonth" placeholder="Month" contenteditable="false">
        </div>
        <div class="form-group col-md-6">
            <input type="text" class="form-control" id="cardYear" v-model="cardYear" placeholder="Year" contenteditable="false">
        </div>
        <div class="form-group col-md-12">
            <input type="text" class="form-control" id="cardPAC" v-model="cardPAC" placeholder="Premier Access Code">
        </div>
        <div class="clearfix"></div>
    </form>

    <div class="row text-center">
        <hr>
        <button type="button" v-on:click="submit" class="btn btn-primary col-md-8 col-md-offset-2">Pay</button>
        <br class="">
    </div>
  </my-modal>


</div>
</template>

<script>
import axios from "axios";
import socket from "./socket";
import auth from "./auth";
import moment from "moment";

export default {
    data: function() {
        return {
            cardNumber: "19293748203910",
            cardMonth: "12",
            cardYear: "20",
            cardPAC: "123",
            showModal: false,
            parking_address: "",
            message: "",
            payment_type: "Real Time",
            parking_start_time: new Date(),
            parking_end_time: null,
            parking_search_radius: '100 meters',
            payment_selected: "Before Parking",
            config: {
              useCurrent: false,
              showClear: true,
              showClose: true,
            },
            lotSearchingResult: null,
            paymentParams: null
        }
    },
    methods: {
        submit: function() {
          if(this.lotSearchingResult != null){
            axios.post("/api/bookings",
                {parking_address: this.lotSearchingResult,
                paymentParams: this.paymentParams},
                {headers: auth.getAuthHeader()})
                .then(response => {
                    this.lotSearchingResult = null;
                    document.getElementById("btn_submit").style.display = "none";
                    document.getElementById("btn_submit2").style.display = "none";
                    document.getElementById("btn_search").click();
                    document.getElementById("btn_modal").click();
                    console.log(response.data);
                    alert(response.data.msg);
                })
                .catch(error => {
                    console.log(error);
                });
            }
        },
        dateTimeStatusRead: function(){
          document.getElementById("parking_end_time").readOnly = true;
          document.getElementById("payment_type").getElementsByTagName("option")[1].disabled = true;
          this.payment_selected = "End of Month";
        },
        dateTimeStatusWrite: function(){
          document.getElementById("parking_end_time").readOnly = false;
          document.getElementById("payment_type").getElementsByTagName("option")[1].disabled = false;
          this.payment_selected = "Before Parking";
        },
        search: function() {
          this.lotSearchingResult = null;
          this.geocoder = new google.maps.Geocoder;
          this.geocoder.geocode({address:this.parking_address}, (results, status)=>{
            if (status == 'OK') {
              var lngLat = {
                lng: results[0].geometry.location.lng(),
                lat: results[0].geometry.location.lat()
              }

              var startDateTime = this.parking_start_time;
              if (this.payment_type == "Real Time"){
                var endDateTime = null;
              } else {
                var endDateTime = this.parking_end_time;
              }

              try {
                  var startTime = (startDateTime != null ) ? startDateTime.toISOString() : null;
                  var endTime = (endDateTime != null) ? endDateTime.toISOString() : null;
              }
              catch(err) {
                  var startTime = (startDateTime != null ) ? startDateTime : null;
                  var endTime = (endDateTime != null) ? endDateTime : null;

                  startTime = moment(String(startTime)).format('YYYY-MM-DDTHH:mm:ss.SSS') + "Z";
                  endTime = (endTime != null) ? moment(String(endTime)).format('YYYY-MM-DDTHH:mm:ss.SSS') + "Z" : null;

              }
              axios.post("/api/search",
                  { lngLat: lngLat,
                    startDateTime: startTime,
                    endDateTime: endTime,
                    parkingSearchRadius: this.parking_search_radius,
                    paymentTime: this.payment_selected,
                    paymentType: this.payment_type
                    },
                  {headers: auth.getAuthHeader()})
                  .then(response => {
                      var searchingResult = response.data;
                      if(searchingResult.length > 0 && this.payment_selected == "Before Parking"){
                        document.getElementById("btn_submit").style.display = "none";
                      } else if(searchingResult.length > 0) {
                        document.getElementById("btn_submit").style.display = "none";
                        document.getElementById("btn_submit2").style.display = "none";
                      } else {
                        document.getElementById("btn_submit").style.display = "none";
                      }

                      console.log(searchingResult);

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

                      for(var j = 0; j < searchingResult.length; j++){
                        for(var i = 0; i < searchingResult[j].area.length; i++){
                          var coord = [searchingResult[j].id, searchingResult[j].area[i].lat, searchingResult[j].area[i].lng,
                                        searchingResult[j].zone.costHourly,
                                        searchingResult[j].zone.costRealTime,
                                        searchingResult[j].zone.description,
                                        searchingResult[j].zone.freeTimeLimit,
                                        searchingResult[j].startDateTime,
                                        searchingResult[j].endDateTime,
                                        searchingResult[j].paymentTime,
                                        searchingResult[j].paymentType,
                                        searchingResult[j].shape,
                                        searchingResult[j].capacity];
                        }
                        coordsForMarker[j] = coord;
                      }

                      for(var j = 0; j < searchingResult.length; j++){

                        var color = "#FF0000";
                        var shape = searchingResult[j].shape;

                        var flightPlanCoordinates = [];
                        for(var x = 0; x < searchingResult[j].area.length; x++){
                            var coortinates = {lat: searchingResult[j].area[x].lat, lng: searchingResult[j].area[x].lng}
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
                      var that = this;
                      var markerCoords = [];
                      var parkingCosts = [];
                      for (var i = 0; i < coordsForMarker.length; i++) {
                        marker = new google.maps.Marker({
                          position: new google.maps.LatLng(coordsForMarker[i][1], coordsForMarker[i][2]),
                          map: map
                        });

                        var infowindow = new google.maps.InfoWindow({});

                        google.maps.event.addListener(marker, 'click', (function(marker, i) {

                          var contenString = "Description: This parking belongs to " + coordsForMarker[i][5] +    ". <br>"
                          var cost = null;

                          if(that.payment_type == "Hourly"){
                            var paymentTypeString = "Hourly payment is " + coordsForMarker[i][3] +   " Euro. <br>";
                            var hourlyFee = (coordsForMarker[i][5] == zoneA) ? (2/3600) : (1/3600);
                            cost = ((new Date(that.parking_end_time) - new Date(that.parking_start_time))/36e5*36e2) * hourlyFee;
                            cost = cost.toFixed(2);
                            paymentTypeString += "Total cost is " + cost + " Euro. <br>";
                          } else{
                            var paymentTypeString = "Real Time payment is " + coordsForMarker[i][4] +  " Euro. <br>";
                          }

                          if(that.payment_selected == "Before Parking" && that.payment_type == "Hourly"){
                            var contenStringBtn = "<input type='button' value='Choose' onclick='document.getElementById(\"btn_submit\").click()'>";
                          } else {
                            var contenStringBtn = "<input type='button' value='Choose' onclick='document.getElementById(\"btn_submit2\").click()'>";
                          }

                          if(coordsForMarker[i][5] == zoneB || coordsForMarker[i][5] == zoneA){
                            contenString += paymentTypeString +
                                            "Free time limit is " + coordsForMarker[i][6] + " minutes. <br>"
                          } else {
                            cost = null;
                          }

                          contenString += "Capacity is " + coordsForMarker[i][12] +    " lots. <br> <br>" + contenStringBtn;

                          markerCoords[i] = {id: coordsForMarker[i][0],endDateTime: coordsForMarker[i][8],startDateTime: coordsForMarker[i][7],
                            paymentTime: coordsForMarker[i][9],paymentType: coordsForMarker[i][10],
                            lat: coordsForMarker[i][1], lng: coordsForMarker[i][2]};

                          parkingCosts[i] = {cost: cost};

                          return function() {
                            that.lotSearchingResult = markerCoords[i];
                            that.paymentParams = parkingCosts[i];
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
        },
        myFunction: function(){
          console.log("worked!");
        }
    },
    mounted: function() {

        Date.prototype.addHours= function(h){
            this.setHours(this.getHours()+h);
            return this;
        };

        this.parking_end_time = new Date().addHours(1);

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
          document.getElementById("parking_end_time").readOnly = true;
          document.getElementById("payment_type").getElementsByTagName("option")[1].disabled = true;
          this.payment_selected = "End of Month";
        } else {
          document.getElementById("parking_end_time").readOnly = false;
          document.getElementById("payment_type").getElementsByTagName("option")[1].disabled = false;
          this.payment_selected = "Before Parking";
        }

        if (auth.socket) {
          var channel = auth.getChannel("customer:");
          channel.join()
              .receive("ok", resp => { console.log("Joined successfully", resp) })
              .receive("error", resp => { console.log("Unable to join", resp) });
          channel.on("requests", payload => {
              alert(payload);
          });
      }
  }
}
</script>
