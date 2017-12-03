import Vue from "vue";
import VueRouter from "vue-router";

import "axios";
import "./socket";
import "phoenix";
import auth from "./auth";

import booking from "./booking";
// import driver from "./driver";
// import mymap from "./mymap";
import login from "./login";
import main from "./main";
import $ from "jquery";

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
    .toggleClass("glyphicon-certificate");
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
