<template>
  <div>
    <h1 id="projectName">TARTUPARK</h1>
    <booking></booking>
    <ul id="listBtns">
        <li style="display: inline-block;"><router-link class="btn btn-default" :to="{ name: 'summary'}">Booking History</router-link></li>
        <li style="display: inline-block;"><p <a href="/login" class="btn btn-default" @click.prevent="logout">Log out</a></p></li>
    </ul>
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

<style>
.header {
    border-bottom: 0px;
}

#projectName{
     text-align: center; 
     text-transform: uppercase; 
     color: #008CBA;
     font-weight: bold;
}

#listBtns{
    margin-right: 60px;
    float: right;
}

</style>

