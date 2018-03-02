import Vue from 'vue/dist/vue.esm.js'
import VueRouter from 'vue-router'

import Index from '../index.vue'
import NewTodo from '../new_todo.vue'
import Sign_in from '../sign_in.vue'
import Sign_up from '../sign_up.vue'
import User_edit from '../user_edit.vue'

Vue.use(VueRouter)

export default new VueRouter({
  mode: 'history',
  routes: [
    { path: '/', component: Index },
    { path: '/new', component: NewTodo},
    { path: '/sign_in', component: Sign_in},
    { path: '/sign_up', component: Sign_up},
    { path: '/user_edit', component: User_edit},
  ],
})
