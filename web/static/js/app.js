import Vue from "vue";
import VueRouter from "vue-router";

import "axios";
import "./socket";
import "phoenix";
import auth from "./auth";

import customer from "./customer";
// import driver from "./driver";
// import mymap from "./mymap";
import login from "./login";
import main from "./main";

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

Vue.component("customer", customer);
// Vue.component("driver", driver);
// Vue.component("mymap", mymap);
// Vue.component("login", login);
// Vue.component("main", main);

var router = new VueRouter({
    routes:[
        {path: '/login', component: login, beforeEnter: afterAuth},
        {path: '/', component: main, beforeEnter: requireAuth},
        {path: '*', redirect: '/'}
    ]
});

new Vue({ router }).$mount("#tartupark-app");
// new Vue({ el: "#tartupark-app" });

