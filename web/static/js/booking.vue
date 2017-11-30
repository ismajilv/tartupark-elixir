<template>
<div>
  <div class="form-group">
    <label class="control-label col-sm-3" for="pickup_address">Parking address:</label>
    <div class="col-sm-9">
      <input type="text" class="form-control" id="pickup_address" v-model="parking_address">
    </div>
  </div>
  <div class="form-group">
    <div class="col-sm-offset-3 col-sm-9">
      <button class="btn btn-default" id="summit-booking" v-on:click="submitBookingRequest">Submit</button>
    </div>
  </div>

<!--
  <div class="col-sm-12" style="bcc-removed:f4f7ff;height:40pt">{{messages}}</div>
  <div id="map" style="width:100%;height:300px"></div>
-->

  <div id="map" style="width=100%; height: 500px;"></div>

</div>


<!-- <script async defer
        src="https://maps.googleapis.com/maps/api/js?key=<%= Application.get_env(:tartupark, :gmaps_api_key) %>"
        type="text/javascript"></script> -->


</template>

<script>
import axios from "axios";
import auth from "./auth";

export default {
    data: function() {
        return {
            pickup_address: "Liivi 2, Tartu, Estonia",
            dropoff_address: "Narva mnt. 25, Tartu, Estonia",
            messages: ""
        }
    },
    methods: {
        // submitBookingRequest: function() {
        //     axios.post("/api/bookings",
        //         {pickup_address: this.pickup_address, dropoff_address: this.dropoff_address},
        //         {headers: auth.getAuthHeader()})
        //         .then(response => {
        //             // console.log(response.data.msg);
        //             // document.getElementById("msg").innerHTML = response.data.msg;
        //             this.messages = response.data.msg;
        //         }).catch(error => {
        //             console.log(error);
        //         });
        // }
    },
    mounted: function() {

      navigator.geolocation.getCurrentPosition(position => {
        let loc = {lat: position.coords.latitude, lng: position.coords.longitude};
        var geocoder = new google.maps.Geocoder;
        var map = new google.maps.Map(document.getElementById('map'), {zoom: 4, center: loc});
        var marker = google.maps.Marker({position: loc, map: map});
        geocoder.geocode({location: loc}, (results, status) => {
          if (status === "OK" && results[0])
            this.pickup_address = results[0].formatted_address;
          });
      });

        // if (auth.socket) {
        //     var channel = auth.getChannel("customer:");
        //     channel.join()
        //         .receive("ok", resp => { console.log("Joined successfully", resp) })
        //         .receive("error", resp => { console.log("Unable to join", resp) });

            // channel.on("requests", payload => {
            //     this.messages = payload.msg;
            //     // this.messages += "\n" + payload.msg;
            // });
        // }
    }
}
</script>
