import Vue from "vue";
import VueRouter from "vue-router";

import login from "./login";
import main from "./main";

import "phoenix";
import "axios";
import "./socket";

import auth from './auth'

Vue.use(VueRouter);

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
}).$mount("#takso-app");
