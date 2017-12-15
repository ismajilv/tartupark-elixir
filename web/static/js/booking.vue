<template>
    <div class="row">
        <div class="col-sm-12" id="mapDiv">
            <div class="center">

                <input type="text" class="form-control search-field" id="parking_address" v-model="parking_address">
                <button type="submit" class="btn btn-default" id="btn_map"><i class="glyphicon glyphicon-list"></i></button>
                    
                <date-picker v-model="parking_start_time" :config="config" class="search-field" id="parking_start_time"  ></date-picker>
            
                <date-picker v-model="parking_end_time" :config="config" class="search-field" id="parking_end_time"  ></date-picker>
        
                <div id="radioBtn" class="btn-group search-field">
                    <a class="btn btn-primary btn-sm notActive radioBtn" data-toggle="fun" data-title="Y" v-on:click="dateTimeStatusWrite">Hourly</a>
                    <a class="btn btn-primary btn-sm active radioBtn" data-toggle="fun" data-title="X" v-on:click="dateTimeStatusRead">Real Time</a>

                    <select class="select" id="payment_type" v-model="payment_selected">
                        <option disabled value="">When will you pay?</option>
                        <option>Before Parking</option>
                        <option>End of Month</option>
                    </select>
                </div>

                <div class="btn-group search-field" id="searchRadiusContainer"  >
                    <input type="range" min="100" max="1000" value="500" step="50" class="slider" id="myRange">
                    <p id="radiusPanel">Radius: <span id="demo"></span></p>
                </div>

                <div class="btn-group search-field" id="buttons">
                    <button class="btn btn-default" @click="showModal=true" style="display: none;" id="btn_submit">Submit</button>
                    <button type="submit" class="btn btn-default" id="btn_submit2" style="display: none;" v-on:click="submit">Submit</button>
                    <button type="submit" class="btn btn-default" id="btn_search" v-on:click="search">Search</button>
                </div>

            </div>

            <div id="usercridentials">
                <ul id="listBtns">
                    <button type="submit" class="btn btn-default" id="btn_usr" style="padding: 3px 6px !important;"><i class="glyphicon glyphicon-user"></i></button>
                    <li class="ul-li"><router-link class="btn btn-default usercridentials-btns" :to="{ name: 'summary'}">Booking History</router-link></li>
                    <li class="ul-li"><p <a href="/login" class="btn btn-default usercridentials-btns" @click.prevent="logout">Log out</a></p></li>
                </ul>
            </div>


            <div id="map"></div>

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
    </div>
</template>

<script>
import axios from "axios";
import socket from "./socket";
import auth from "./auth";
import moment from "moment";
import "vueify/lib/insert-css";

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
        fullScreenMap: function(){
            // var handler;
            // handler = Gmaps.build("Google");
            
            // return handler.buildMap({
            //     internal: {
            //         id: "map"
            //     }
            // }, function() {
            //     handler.fitMapToBounds();
            // });
        },
        logout: function() {
            auth.logout(this, { headers: auth.getAuthHeader() });
        },
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
          this.payment_type = "Real Time";
        },
        dateTimeStatusWrite: function(){
          document.getElementById("parking_end_time").readOnly = false;
          document.getElementById("payment_type").getElementsByTagName("option")[1].disabled = false;
          this.payment_selected = "Before Parking";
          this.payment_type = "Hourly";
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
              
              var startTime = (startDateTime != null ) ? startDateTime : null;
              var endTime = (endDateTime != null) ? endDateTime : null;

              startTime = moment(String(startTime)).format('YYYY-MM-DDTHH:mm:ss.SSS') + "Z";
              endTime = (endTime != null) ? moment(String(endTime)).format('YYYY-MM-DDTHH:mm:ss.SSS') + "Z" : null;

              var radius = document.getElementById("myRange").value;

              axios.post("/api/search",
                  { lngLat: lngLat,
                    startDateTime: startTime,
                    endDateTime: endTime,
                    parkingSearchRadius: radius,
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


                    document.getElementById("parking_start_time").style.display = "none";
                    document.getElementById("parking_end_time").style.display = "none";
                    document.getElementById("radioBtn").style.display = "none";
                    document.getElementById("searchRadiusContainer").style.display = "none";
                    document.getElementById("btn_search").style.display = "none";

                      var map = new google.maps.Map(document.getElementById('map'), {
                        zoom: 14,
                        center: lngLat,
                        mapTypeId: google.maps.MapTypeId.ROADMAP,
                        styles:[   {     "elementType": "geometry",     "stylers": [       {         "color": "#ebe3cd"       }     ]   },   {     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#523735"       }     ]   },   {     "elementType": "labels.text.stroke",     "stylers": [       {         "color": "#f5f1e6"       }     ]   },   {     "featureType": "administrative",     "elementType": "geometry.stroke",     "stylers": [       {         "color": "#c9b2a6"       }     ]   },   {     "featureType": "administrative.land_parcel",     "elementType": "geometry.stroke",     "stylers": [       {         "color": "#dcd2be"       }     ]   },   {     "featureType": "administrative.land_parcel",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#ae9e90"       }     ]   },   {     "featureType": "landscape.natural",     "elementType": "geometry",     "stylers": [       {         "color": "#dfd2ae"       }     ]   },   {     "featureType": "poi",     "elementType": "geometry",     "stylers": [       {         "color": "#dfd2ae"       }     ]   },   {     "featureType": "poi",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#93817c"       }     ]   },   {     "featureType": "poi.park",     "elementType": "geometry.fill",     "stylers": [       {         "color": "#a5b076"       }     ]   },   {     "featureType": "poi.park",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#447530"       }     ]   },   {     "featureType": "road",     "elementType": "geometry",     "stylers": [       {         "color": "#f5f1e6"       }     ]   },   {     "featureType": "road.arterial",     "elementType": "geometry",     "stylers": [       {         "color": "#fdfcf8"       }     ]   },   {     "featureType": "road.highway",     "elementType": "geometry",     "stylers": [       {         "color": "#f8c967"       }     ]   },   {     "featureType": "road.highway",     "elementType": "geometry.stroke",     "stylers": [       {         "color": "#e9bc62"       }     ]   },   {     "featureType": "road.highway.controlled_access",     "elementType": "geometry",     "stylers": [       {         "color": "#e98d58"       }     ]   },   {     "featureType": "road.highway.controlled_access",     "elementType": "geometry.stroke",     "stylers": [       {         "color": "#db8555"       }     ]   },   {     "featureType": "road.local",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#806b63"       }     ]   },   {     "featureType": "transit.line",     "elementType": "geometry",     "stylers": [       {         "color": "#dfd2ae"       }     ]   },   {     "featureType": "transit.line",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#8f7d77"       }     ]   },   {     "featureType": "transit.line",     "elementType": "labels.text.stroke",     "stylers": [       {         "color": "#ebe3cd"       }     ]   },   {     "featureType": "transit.station",     "elementType": "geometry",     "stylers": [       {         "color": "#dfd2ae"       }     ]   },   {     "featureType": "water",     "elementType": "geometry.fill",     "stylers": [       {         "color": "#b9d3c2"       }     ]   },   {     "featureType": "water",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#92998d"       }     ]   } ]
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

                          var contenString = "<div id='parkingPlaceInformation'> <h4 id='parkingPlaceH4'>Parking Place Information</h4> <p id='parkingPlaceParagraph'>"
                          contenString += "Description: This parking belongs to <strong>" + coordsForMarker[i][5] +    "</strong>. <br>"
                          var cost = null;

                          if(that.payment_type == "Hourly"){
                            var paymentTypeString = "Hourly payment is <strong>" + coordsForMarker[i][3] +   "</strong> Euro. <br>";
                            var hourlyFee = (coordsForMarker[i][5] == zoneA) ? (2/3600) : (1/3600);
                            cost = ((new Date(that.parking_end_time) - new Date(that.parking_start_time))/36e5*36e2) * hourlyFee;
                            cost = cost.toFixed(2);
                            paymentTypeString += "Total cost is <strong>" + cost + "</strong> Euro. <br>";
                          } else{
                            var paymentTypeString = "Real Time payment is <strong>" + coordsForMarker[i][4] +  "</strong> Euro. <br>";
                          }

                          if(that.payment_selected == "Before Parking" && that.payment_type == "Hourly"){
                            
                            if(coordsForMarker[i][5] == zoneB || coordsForMarker[i][5] == zoneA){
                              var contenStringBtn = "<input type='button' class='btnInfowWindow' value='Book a place from this zone' onclick='document.getElementById(\"btn_submit\").click()'>";
                            } else {
                              var contenStringBtn = "<input type='button' class='btnInfowWindow' value='Book a place from this zone' onclick='document.getElementById(\"btn_submit2\").click()'>";  
                            }

                          } else {
                            var contenStringBtn = "<input type='button' class='btnInfowWindow' value='Book a place from this zone' onclick='document.getElementById(\"btn_submit2\").click()'>";
                          }

                          if(coordsForMarker[i][5] == zoneB || coordsForMarker[i][5] == zoneA){
                            contenString += paymentTypeString +
                                            "Free time limit is <strong>" + coordsForMarker[i][6] + "</strong> minutes. <br>"
                          } else {
                            cost = null;
                          }

                          contenString += "Capacity is <strong>" + coordsForMarker[i][12] +    "</strong> lots. <br> <br>" + contenStringBtn;
                          contenString += "</p></div>"

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
        }
    },
    mounted: function() {

        // visibility
        document.getElementById("parking_start_time").style.display = "none";
        document.getElementById("parking_end_time").style.display = "none";
        document.getElementById("radioBtn").style.display = "none";
        document.getElementById("searchRadiusContainer").style.display = "none";
        document.getElementById("btn_search").style.display = "none";

        var that = this;
        var flag = false;
        var flagUser = false;

        $(document).ready(function(){
            $("#btn_map").click(function(){

                console.log("payment type: " + that.payment_type);

                if (that.payment_type == "Real Time"){
                    document.getElementById("parking_end_time").readOnly = true;
                    document.getElementById("payment_type").getElementsByTagName("option")[1].disabled = true;
                    this.payment_selected = "End of Month";
                } else {
                    document.getElementById("parking_end_time").readOnly = false;
                    document.getElementById("payment_type").getElementsByTagName("option")[1].disabled = false;
                    that.payment_selected = "Before Parking";
                }

                if(this.flag){
                    $("#parking_start_time").fadeOut("slow");
                    $("#parking_end_time").fadeOut("slow");
                    $("#radioBtn").fadeOut("slow");
                    $("#searchRadiusContainer").fadeOut("slow");
                    $("#btn_search").fadeOut("slow");

                    this.flag = false;

                } else {
                    $("#parking_start_time").fadeIn("slow");
                    $("#parking_end_time").fadeIn("slow");
                    $("#radioBtn").fadeIn("slow");
                    $("#searchRadiusContainer").fadeIn("slow");
                    $("#btn_search").fadeIn("slow");


                    this.flag = true;

                }
            });


            $("#btn_usr").click(function(){
                
                if(this.flagUser){
                    $(".ul-li").fadeOut("slow");
                    this.flagUser = false;

                } else {
                    $(".ul-li").fadeIn("slow");
                    this.flagUser = true;

                }
            });
        });

        // search radius
        var slider = document.getElementById("myRange");
        var output = document.getElementById("demo");
        output.innerHTML = slider.value;

        slider.oninput = function() {
            output.innerHTML = this.value;
        }

        // radio buttons
        $('#radioBtn a').on('click', function(){
            var sel = $(this).data('title');
            var tog = $(this).data('toggle');
            $('#'+tog).prop('value', sel);
            
            $('a[data-toggle="'+tog+'"]').not('[data-title="'+sel+'"]').removeClass('active').addClass('notActive');
            $('a[data-toggle="'+tog+'"][data-title="'+sel+'"]').removeClass('notActive').addClass('active');
        })

         if (that.payment_type == "Real Time"){
          document.getElementById("parking_end_time").readOnly = true;
          document.getElementById("payment_type").getElementsByTagName("option")[1].disabled = true;
          that.payment_selected = "End of Month";
        } else {
          document.getElementById("parking_end_time").readOnly = false;
          document.getElementById("payment_type").getElementsByTagName("option")[1].disabled = false;
          that.payment_selected = "Before Parking";
        }

        // add date time to end time field
        Date.prototype.addHours= function(h){
            this.setHours(this.getHours()+h);
            return this;
        };
        this.parking_end_time = new Date().addHours(1);

        // find current place of customer
        navigator.geolocation.getCurrentPosition(position => {
            let loc = {lat: position.coords.latitude, lng: position.coords.longitude};
            this.geocoder = new google.maps.Geocoder;
            this.geocoder.geocode({location: loc}, (results, status) => {
                if (status === "OK" && results[0]){
                    this.parking_address = results[0].formatted_address;
                    console.log("parking address: " + this.parking_address);
                }else {
                    alert('Geocode was not successful for the following reason: ' + status);
                }
            });
            this.map = new google.maps.Map(document.getElementById('map'), {zoom: 14, center: loc, styles:[   {     "elementType": "geometry",     "stylers": [       {         "color": "#ebe3cd"       }     ]   },   {     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#523735"       }     ]   },   {     "elementType": "labels.text.stroke",     "stylers": [       {         "color": "#f5f1e6"       }     ]   },   {     "featureType": "administrative",     "elementType": "geometry.stroke",     "stylers": [       {         "color": "#c9b2a6"       }     ]   },   {     "featureType": "administrative.land_parcel",     "elementType": "geometry.stroke",     "stylers": [       {         "color": "#dcd2be"       }     ]   },   {     "featureType": "administrative.land_parcel",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#ae9e90"       }     ]   },   {     "featureType": "landscape.natural",     "elementType": "geometry",     "stylers": [       {         "color": "#dfd2ae"       }     ]   },   {     "featureType": "poi",     "elementType": "geometry",     "stylers": [       {         "color": "#dfd2ae"       }     ]   },   {     "featureType": "poi",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#93817c"       }     ]   },   {     "featureType": "poi.park",     "elementType": "geometry.fill",     "stylers": [       {         "color": "#a5b076"       }     ]   },   {     "featureType": "poi.park",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#447530"       }     ]   },   {     "featureType": "road",     "elementType": "geometry",     "stylers": [       {         "color": "#f5f1e6"       }     ]   },   {     "featureType": "road.arterial",     "elementType": "geometry",     "stylers": [       {         "color": "#fdfcf8"       }     ]   },   {     "featureType": "road.highway",     "elementType": "geometry",     "stylers": [       {         "color": "#f8c967"       }     ]   },   {     "featureType": "road.highway",     "elementType": "geometry.stroke",     "stylers": [       {         "color": "#e9bc62"       }     ]   },   {     "featureType": "road.highway.controlled_access",     "elementType": "geometry",     "stylers": [       {         "color": "#e98d58"       }     ]   },   {     "featureType": "road.highway.controlled_access",     "elementType": "geometry.stroke",     "stylers": [       {         "color": "#db8555"       }     ]   },   {     "featureType": "road.local",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#806b63"       }     ]   },   {     "featureType": "transit.line",     "elementType": "geometry",     "stylers": [       {         "color": "#dfd2ae"       }     ]   },   {     "featureType": "transit.line",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#8f7d77"       }     ]   },   {     "featureType": "transit.line",     "elementType": "labels.text.stroke",     "stylers": [       {         "color": "#ebe3cd"       }     ]   },   {     "featureType": "transit.station",     "elementType": "geometry",     "stylers": [       {         "color": "#dfd2ae"       }     ]   },   {     "featureType": "water",     "elementType": "geometry.fill",     "stylers": [       {         "color": "#b9d3c2"       }     ]   },   {     "featureType": "water",     "elementType": "labels.text.fill",     "stylers": [       {         "color": "#92998d"       }     ]   } ]});
            new google.maps.Marker({position: loc, map: this.map, title: "Parking address"});
        });

        this.fullScreenMap();

       
  }
}
</script>


<style>

#mapDiv, #map {
    height: 100%;
    width: 100%;
    position: static !important;
}

.center {
    position: absolute;
    width: 40%;
    height: 40px;
    top: 10%;
    z-index: 999999;
    text-align: center;
}

#usercridentials{
    position: absolute;
    width: 40%;
    height: 40px;
    top: 10%;    
    right: 12px;
    z-index: 999999;
    text-align: right;
}

.ul-li{
    text-align: right;
    margin-top: 5px;
    display: none;
}

.usercridentials-btns{
    width: 125px;
}

.search-field{
    position: relative;
    bottom: -50%;
    padding: 14px 8px;
    font-family: 'Source Sans Pro', Arial, sans-serif;
    width: 90%;
    height: 100%;
    margin-top: 5px;
}

#btn_map{
    margin-left: -50px;
    height: 38px;
    background: #3333ff;
    color: white;
    border: 0;
    -webkit-appearance: none;
    position: relative;
    float: right;
    margin-right: 52px;
    margin-top: -19px;
}

#radioBtn{
    margin-top: 15px;
    float: left;
    width: 91%;
}

#radioBtn .notActive{
    color: #3276b1;
    background-color: #fff;
}

.radioBtn{
    width: 50%;
}

.select{
    width: 100%;
    margin-top: 10px;
    border-radius: 5%;
}

#searchRadiusContainer{
    margin-top: 35px;
    width: 90%;
    margin-left: -50px;
}

#radiusPanel {
    width: 20%;
    font-weight: bold;
    margin-top: -25px;
    margin-left: 360px;
    background-color: white;
    height: 25px;
    padding-top: 2px;
}

input[type=range] {
    display: block;
    width: 81%;
    margin-top: 10px;
}

.slider {
    -webkit-appearance: none;
    height: 25px;
    background: #fff;
    outline: none;
    opacity: 1;
    -webkit-transition: .2s;
    transition: opacity .2s;
}

.slider:hover {
    opacity: 1;
}

.slider::-webkit-slider-thumb {
    -webkit-appearance: none;
    appearance: none;
    width: 25px;  
    height: 25px;
    background: #008CBA;
    cursor: pointer;
}

.slider::-moz-range-thumb {
    width: 25px;
    height: 25px;
    background: #008CBA;
    cursor: pointer;
}

/* google marker content css */

#parkingPlaceInformation {
    margin: auto;
    padding: 8px;
}

#parkingPlaceH4 {
    text-align: center;
    text-transform: uppercase;
    color: #008CBA;
}

#parkingPlaceParagraph {
    text-align: justify;
    letter-spacing: 3px;
    font-family: "Arial", Helvetica, sans-serif;
}

.btnInfowWindow{
  background-color: #008CBA; 
  border: none;
  color: white;
  padding: 5px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  margin: 4px 2px;
  width: 100%;
  cursor: pointer;
}

#buttons{
    margin-top: 5px;
}

#btn_search{
    float: right;
    margin-right: 20px;
}


</style>
