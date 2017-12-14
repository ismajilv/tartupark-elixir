import Vue from "vue";
import VueRouter from "vue-router";
import moment from "moment";
import datePicker from 'vue-bootstrap-datetimepicker';

import 'eonasdan-bootstrap-datetimepicker';
import "axios";
import "./socket";
import "phoenix";

import auth from "./auth";
import booking from "./booking";
import login from "./login";
import main from "./main";
import summary from "./summary";
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
Vue.use(datePicker);

Vue.component("booking", booking);
Vue.component('my-modal', {
    template: `
            <div class="modal is-active">
                <div class="modal-background"></div>
                <div class="modal-content" style="padding: 25px;">
                    <slot></slot>
                </div>
                <button class="modal-close is-large" id="btn_modal" aria-label="close" @click="$emit('close')"></button>
            </div>
    `
});



var router = new VueRouter({
    routes:[
        {path: '/login', component: login, beforeEnter: afterAuth},
        {path: '/', component: main, beforeEnter: requireAuth},
        {path: '/bookings/summary', component: summary, name: 'summary', beforeEnter: requireAuth},
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
