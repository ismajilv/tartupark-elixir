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
                    <td>{{ (booking.startDateTime).substring(11, 16) + " " + (booking.startDateTime).substring(8, 10) + "/" + (booking.startDateTime).substring(5, 7) + "/" + (booking.startDateTime).substring(0, 4) }}</td>
                    <td>{{ (booking.endDateTime != null) ? (booking.endDateTime).substring(11, 16) + " " + (booking.endDateTime).substring(8, 10) + "/" + (booking.endDateTime).substring(5, 7) + "/" + (booking.endDateTime).substring(0, 4) : null }}</td>
                    <td>{{ booking.paymentTime }}</td>
                    <td>{{ booking.paymentType }}</td>
                    <td>{{ (booking.payment != null) ? booking.payment.payment_code : null }}</td>
                    <td>{{ (booking.payment != null) ? (booking.payment.cost).toFixed(2) : null }}</td>
                    <td class="text-right">
                        <button type="submit" v-if="booking.paymentType == 'Real Time'" class="btn btn-info btn-xs" id="btn_end" v-on:click="endParking(booking.booking_id)">End Parking</button>
                        <button type="submit" v-if="booking.paymentType == 'Hourly'" class="btn btn-danger btn-xs" id="btn_cancel" v-on:click="cancelBooking(booking.booking_id)">Cancel Booking</button>
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
            bookings: [],
            selectedBookingForUpdate: null
        }
    },
    methods: {
        endParking: function(bookingId, parkingEndTime){
            console.log("booking id: " + bookingId);
            axios.patch("/api/bookings/"+bookingId,
            {parkingEndTime: new Date()}, 
            {headers: auth.getAuthHeader()})
            .then(response => {
                console.log(response.data);
            })
            .catch(error => {
                console.log(error);
            });
        },
        cancelBooking: function(bookingId){
            console.log("booking id: " + bookingId);
            axios.delete("/api/bookings/"+bookingId,
            {bookin_id: bookingId}, 
            {headers: auth.getAuthHeader()})
            .then(response => { 
                console.log(response.data);
            })
            .catch(error => {
                console.log(error);
            });
        },
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
