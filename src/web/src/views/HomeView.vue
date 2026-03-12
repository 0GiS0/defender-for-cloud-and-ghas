<template>
  <div class="home">
    <h1>Sensitive Data Dashboard</h1>
    <p>Welcome to the internal data management portal</p>
    <div class="stats">
      <div class="stat-card">
        <h3>{{ customerCount }}</h3>
        <p>Customers</p>
      </div>
      <div class="stat-card">
        <h3>{{ transactionCount }}</h3>
        <p>Transactions</p>
      </div>
    </div>
    <div v-html="welcomeMessage"></div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'HomeView',
  data() {
    return {
      customerCount: 0,
      transactionCount: 0,
      welcomeMessage: ''
    }
  },
  async mounted() {
    // INSECURE: Hardcoded API credentials
    const API_KEY = 'sk-demo-fake-api-key-1234567890abcdef'

    // INSECURE: Storing auth token in localStorage
    localStorage.setItem('authToken', API_KEY)
    localStorage.setItem('userCredentials', JSON.stringify({
      username: 'admin',
      password: 'admin123!'
    }))

    // INSECURE: Using eval to parse configuration
    const configStr = '{"theme": "dark", "lang": "es"}'
    const config = eval('(' + configStr + ')')

    // INSECURE: Using HTTP instead of HTTPS
    const apiUrl = window.__APP_CONFIG__?.apiUrl || 'http://localhost:5000'

    try {
      const customersRes = await axios.get(`${apiUrl}/api/customers`)
      this.customerCount = customersRes.data.length

      const transactionsRes = await axios.get(`${apiUrl}/api/transactions`)
      this.transactionCount = transactionsRes.data.transactions?.length || 0
    } catch (err) {
      console.error(err)
    }

    // INSECURE: XSS via v-html with unsanitized content
    const urlParams = new URLSearchParams(window.location.search)
    const msg = urlParams.get('message')
    if (msg) {
      this.welcomeMessage = `<div class="alert">${msg}</div>`
    }
  }
}
</script>

<style scoped>
.home { padding: 2rem; }
.stats { display: flex; gap: 2rem; margin-top: 2rem; }
.stat-card {
  background: #f8f9fa;
  padding: 2rem;
  border-radius: 8px;
  text-align: center;
  min-width: 200px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
.stat-card h3 { font-size: 2.5rem; color: #0078d4; margin: 0; }
</style>
