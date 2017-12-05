import Vue from "vue";
import VueRouter from "vue-router";
// import VeeValidate from 'vee-validate';

const jQuery = window.jQuery || require("jquery");
// const moment = window.moment || require("moment");

import datePicker from 'vue-bootstrap-datetimepicker';
import 'eonasdan-bootstrap-datetimepicker';
import "axios";
import "./socket";
import "phoenix";
import auth from "./auth";
import booking from "./booking";
import login from "./login";
import main from "./main";
import $ from "jquery";
import "jquery";

const requireAuth = (to, _from, next) => {
    if(!auth.authenticated()){
        next({
            path: '/login',
            query: {redirect: to.fullPath}
        });
    } else{
        next();
    }
}

const afterAuth = (_to, from, next) => {
    if(auth.authenticated()){
        next(from.path);
    } else{
        next();
    }
}

Vue.use(VueRouter);
//Vue.use(VeeValidate);
Vue.use(datePicker);

Vue.component("booking", booking);

var router = new VueRouter({
    routes:[
        {path: '/login', component: login, beforeEnter: afterAuth},
        {path: '/', component: main, beforeEnter: requireAuth},
        {path: '*', redirect: '/'}
    ]
});

new Vue({ router }).$mount("#tartupark-app");


$(".toggle").click(function() {
    // Switches the Icon
    $(this)
      .children("i")
      .toggleClass("glyphicon-arrow-down");
    // Switches the forms
    $(".form").animate(
        {
          height: "toggle",
          "padding-top": "toggle",
          "padding-bottom": "toggle",
          opacity: "toggle"
        },
        "slow"
      );
  });
  
  // $( ".selector" ).slider({
  //   max: 5000,
  //   min: 0,
  //   range: true,
  //   step: 100,
  //   value: 300
  // });
