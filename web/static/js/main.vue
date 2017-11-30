<template>
  <div>
    <p class="pull-right" <a href="/login" @click.prevent="logout">Log out!</a></p>
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
