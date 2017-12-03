<template>
  <div class="module form-module">
    <div class="toggle"><i class="glyphicon glyphicon-certificate"></i>
      <div class="tooltip">Click Me</div>
    </div>
    <div class="form">
      <h2>Login to your account</h2>
      <form>
        <input type="text" placeholder="Username" id="log-username" v-model="username"/>
        <input type="password" placeholder="Password" id="log-password" v-model="password"/>
        <button type="submit" v-on:click="login">Login</button>
      </form>
    </div>

    <div class="form">
      <h2>Create an account</h2>
      <form>
        <input type="text" placeholder="Full Name" id="reg-fullname" v-model="reg_fullname"/>
        <input type="text" placeholder="Username" id="reg-username" v-model="reg_username"/>
        <input type="password" placeholder="Password" id="reg-password" v-model="reg_password"/>
        <input type="email" placeholder="Email Address" id="reg-email" v-model="reg_email"/>
        <input type="text" placeholder="Driving License Number" id="reg-license-number" v-model="reg_license_number"/>
        <button type="submit" v-on:click="signup">Register</button>
      </form>
    </div>

  </div>
</template>

<script>
  import auth from "./auth";
  import axios from "axios";

  export default {
    user: function(){
      return {
          username: "",
          password: "",
          reg_fullname: "",
          reg_username: "",
          reg_password: "",
          reg_email: "",
          reg_license_number: ""
      }
    },
    methods:{
      login: function () {
        let login_data = {
          username: this.username,
          password: this.password
        }
        console.log(`Username ${this.username}, password ${this.password}`);
        auth.login(this, login_data, "/");
      },
      signup: function(){
        let registration_data = {
          username: this.reg_username,
          password: this.reg_password,
          fullName: this.reg_fullname,
          email: this.reg_email,
          license_number: this.reg_license_number
        }
        auth.signup(this, registration_data, "/");
      }
    }
  }
</script>
