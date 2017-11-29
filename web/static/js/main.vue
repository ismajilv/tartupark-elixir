<template>
  <div>
    <a href="/login" @click.prevent="logout">Log out!</a>
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
