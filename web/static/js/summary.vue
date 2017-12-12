<template>
    <h2>Listing users</h2> 

</template>

<script>
import axios from "axios";
import socket from "./socket";
import auth from "./auth";

export default {
    data: function() {
        return {
            
        }
    },
    methods: {
       
    },
    mounted: function() {

        function getSummary(){
           axios.get("/api/bookings/summary", {headers: auth.getAuthHeader()})
            .then(response => { 
                console.log(response.data);
                // alert(response.data.msg);
            })
            .catch(error => {
                console.log(error);
            });
        }

        getSummary();

    }
}
</script>
