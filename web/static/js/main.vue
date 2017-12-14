<template>
  <div>
    <ul>
        <li style="display: inline-block;"><p <a href="/login" class="btn btn-default" @click.prevent="logout">Log out</a></p></li>
        <li style="display: inline-block;"><router-link class="btn btn-default" :to="{ name: 'summary'}">Booking History</router-link></li>
    </ul>
    <booking></booking>
  </div>
</template>


<script>
import auth from "./auth";

export default {
    methods: {
        logout: function() {
            auth.logout(this, { headers: auth.getAuthHeader() });
        }
    }
}
</script>
