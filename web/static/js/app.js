import Vue from "vue";
import VueRouter from "vue-router";

import login from "./login";
import main from "./main";
import booking from "./booking";

import "phoenix";
import "axios";
import "./socket";
import $ from "jquery";

import auth from './auth'

Vue.use(VueRouter);
Vue.component("booking", booking);

const requireAuth = (to, _from, next) => {
  if (!auth.authenticated()) {
    next({
      path: '/login',
      query: { redirect: to.fullPath }
    });
  } else {
    next();
  }
}

const afterAuth = (_to, from, next) => {
  if (auth.authenticated()) {
    next(from.path);
  } else {
    next();
  }
}

var router = new VueRouter({
    routes: [
        { path: '/login', component: login, beforeEnter: afterAuth },
        { path: '/', component: main, beforeEnter: requireAuth },
        { path: '*', redirect: '/' }
    ]
});

new Vue({
    router
}).$mount("#tartupark-app");



$(".toggle").click(function() {
  // Switches the Icon
  $(this)
    .children("i")
    .toggleClass("fa-pencil");
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
