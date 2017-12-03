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
      <button class="btn btn-default" id="summit-booking">Submit</button>
    </div>
  </div>

  <div id="googleMap" style="height:400px;width:100%;"></div>

</div>

</template>

<script>
import axios from "axios";
import auth from "./auth";

export default {
    data: function() {
        return {
            parking_address: "Liivi 2, Tartu, Estonia"
        }
    },
    methods: {
    }
  
}
</script>

