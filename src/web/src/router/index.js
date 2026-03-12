import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import CustomersView from '../views/CustomersView.vue'
import TransactionsView from '../views/TransactionsView.vue'

const routes = [
  { path: '/', name: 'home', component: HomeView },
  { path: '/customers', name: 'customers', component: CustomersView },
  { path: '/transactions', name: 'transactions', component: TransactionsView }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
