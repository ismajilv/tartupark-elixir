<template>
    <div class="table-responsive">
        <table class="table">
            <thead>
                <tr>
                    <th>Booking Start Time</th>
                    <th>Booking End Time</th>
                    <th>Payment Time</th>
                    <th>Payment Type</th>
                    <th>Payment Number</th>
                    <th>Booking Cost</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="booking in bookings" :key="booking.booking_id">
                    <td>{{ (booking.startDateTime).substring(0, 10) + " " + (booking.startDateTime).substring(11, 16) }}</td>           
                    <td>{{ (booking.endDateTime != null) ? (booking.endDateTime).substring(0, 10) + " " + (booking.endDateTime).substring(11, 16) : null }}</td>           
                    <td>{{ booking.paymentTime }}</td>     
                    <td>{{ booking.paymentType }}</td>
                    <td>{{ (booking.payment != null) ? booking.payment.payment_code : null }}</td>
                    <td>{{ (booking.payment != null) ? booking.payment.cost : null }}</td>
                    <td class="text-right">
                        <button class: "btn btn-info">End Parking</button>
                        <button class: "btn btn-danger btn-xs">Cancel Booking</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

    
</template>

<script>
import axios from "axios";
import socket from "./socket";
import auth from "./auth";


export default {
    data: function() {
        return {
            bookings: []
        }
    },
    methods: {
        getSummary: function(){
            axios.get("/api/bookings/summary", {headers: auth.getAuthHeader()})
            .then(response => { 
                console.log(response.data.bookings);
                this.bookings = response.data.bookings;
            })
            .catch(error => {
                console.log(error);
            });
        }
    },
    mounted: function() {
        this.getSummary();
    }
}
</script>
