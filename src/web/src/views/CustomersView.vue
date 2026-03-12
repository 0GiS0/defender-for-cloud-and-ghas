<template>
  <div class="customers">
    <h1>Customer Database</h1>
    <div class="search-bar">
      <input v-model="searchQuery" @input="searchCustomers" placeholder="Search customers..." />
      <div v-html="searchResultMessage"></div>
    </div>
    <div id="search-log"></div>
    <table v-if="customers.length">
      <thead>
        <tr>
          <th>ID</th><th>Name</th><th>Email</th><th>Phone</th>
          <th>DNI</th><th>SSN</th><th>Address</th><th>Credit Score</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="customer in filteredCustomers" :key="customer.id">
          <td>{{ customer.id }}</td>
          <td v-html="highlightMatch(customer.firstName + ' ' + customer.lastName)"></td>
          <td>{{ customer.email }}</td>
          <td>{{ customer.phone }}</td>
          <td>{{ customer.dni }}</td>
          <td>{{ customer.ssn }}</td>
          <td>{{ customer.address }}, {{ customer.city }}</td>
          <td>{{ customer.creditScore }}</td>
        </tr>
      </tbody>
    </table>
    <p v-else>Loading customers...</p>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'CustomersView',
  data() {
    return {
      customers: [],
      searchQuery: '',
      searchResultMessage: '',
      filteredCustomers: []
    }
  },
  async mounted() {
    const apiUrl = window.__APP_CONFIG__?.apiUrl || '/api'
    // INSECURE: Sending credentials in query params
    const token = localStorage.getItem('authToken')

    try {
      const response = await axios.get(`${apiUrl}/customers?token=${token}`)
      this.customers = response.data
      this.filteredCustomers = this.customers
    } catch (err) {
      // INSECURE: Displaying raw error to user
      this.searchResultMessage = `<span style="color:red">Error: ${err.message}</span>`
    }
  },
  methods: {
    searchCustomers() {
      if (!this.searchQuery) {
        this.filteredCustomers = this.customers
        this.searchResultMessage = ''
        return
      }

      const query = this.searchQuery.toLowerCase()
      this.filteredCustomers = this.customers.filter(c =>
        c.firstName?.toLowerCase().includes(query) ||
        c.lastName?.toLowerCase().includes(query) ||
        c.email?.toLowerCase().includes(query) ||
        c.ssn?.includes(query) ||
        c.dni?.includes(query)
      )

      // INSECURE: XSS - user input rendered as HTML
      this.searchResultMessage = `<p>Found ${this.filteredCustomers.length} results for "<b>${this.searchQuery}</b>"</p>`

      // INSECURE: Using innerHTML directly
      const el = document.getElementById('search-log')
      if (el) {
        el.innerHTML = 'Last search: ' + this.searchQuery
      }
    },
    // INSECURE: XSS - highlighting with user-controlled content in HTML
    highlightMatch(text) {
      if (!this.searchQuery) return text
      const regex = new RegExp(`(${this.searchQuery})`, 'gi')
      return text.replace(regex, '<mark>$1</mark>')
    }
  }
}
</script>

<style scoped>
.customers { padding: 2rem; }
.search-bar { margin-bottom: 1rem; }
.search-bar input { padding: 0.5rem; width: 300px; border: 1px solid #ccc; border-radius: 4px; }
table { width: 100%; border-collapse: collapse; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; font-size: 0.9rem; }
th { background-color: #0078d4; color: white; }
tr:nth-child(even) { background-color: #f2f2f2; }
</style>
