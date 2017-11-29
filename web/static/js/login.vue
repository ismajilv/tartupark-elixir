<template>
  <div class="module form-module">
    <div class="toggle"><i class="fa fa-times fa-pencil"></i>
      <div class="tooltip">Click Me</div>
    </div>
    <div class="form">
      <h2>Login to your account</h2>
      <form>
        <input type="text" placeholder="Username" id="log-username" v-model="log_username"/>
        <input type="password" placeholder="Password" id="log-password" v-model="log_password"/>
        <button type="submit" v-on:click="login">Login</button>
      </form>
    </div>

    <div class="form">
      <h2>Create an account</h2>
      <form>
        <input type="text" placeholder="Username" id="reg-username" v-model="reg_username"/>
        <input type="password" placeholder="Password" id="reg-password" v-model="reg_password"/>
        <input type="email" placeholder="Email Address" id="reg-email" v-model="reg_email"/>
        <button type="submit" v-on:click="signup">Register</button>
      </form>
    </div>

  </div>
</template>

<script>
  export default {
  }
</script>

<style lang="css">
</style>

<script type="text/javascrip">

</script>

<script>
  import auth from "./auth";
  import axios from "axios";

  export default {
    user: function(){
      return {
          log_username: "",
          log_password: "",
          reg_username: "",
          reg_password: "",
          reg_email: ""
      }
    },
    methods:{
      login: function (context, _creds, redirect) {
        let login_data = {
          username: this.log_username,
          password: this.log_password
        }
        axios.post("/api/sessions", login_data)
          .then(response => {
            console.log(response);
          })
          .catch( error => {
              console.log(error);
          });
      },
      signup: function(){

      }
    }
  }
</script>
