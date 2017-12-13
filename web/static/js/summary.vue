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
                        <!-- <button type="submit" v-if="booking.paymentType == 'Real Time'" class="btn btn-info btn-xs" id="btn_end" v-on:click="endParking(booking.booking_id)">End Parking</button> -->
                        <button v-if="booking.paymentType == 'Real Time'" class="btn btn-info btn-xs" @click="showModal=true" v-on:click="sendInfoToPopUp(booking.booking_id)" id="btn_submit">End Parking</button>
                        <button type="submit" v-if="booking.paymentType == 'Hourly'" class="btn btn-danger btn-xs" id="btn_cancel" v-on:click="cancelBooking(booking.booking_id)">Cancel Booking</button>
                    </td>
                </tr>
            </tbody>
        </table>

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
                <button type="submit" class="btn btn-primary col-md-8 col-md-offset-2" id="btn_pay" v-on:click="endParking()">Pay</button>
                <br class="">
            </div>
        </my-modal>
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
            selectedBookingForUpdate: null,
            bookingId: null,
            showModal: false,
            cardNumber: "19293748203910",
            cardMonth: "12",
            cardYear: "20",
            cardPAC: "123"
        }
    },
    methods: {
        endParking: function(){
            axios.patch("/api/bookings/"+ this.bookingId,
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
            {headers: auth.getAuthHeader()})
            .then(response => { 
                console.log(response.data);
            })
            .catch(error => {
                console.log(error);
            });
        },
        sendInfoToPopUp: function(bookingId){
            this.bookingId = bookingId;
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
