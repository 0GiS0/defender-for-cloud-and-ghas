<template>
  <div class="transactions">
    <h1>Transaction Records</h1>
    <div class="filters">
      <select v-model="statusFilter" @change="filterTransactions">
        <option value="">All Statuses</option>
        <option value="Completed">Completed</option>
        <option value="Pending">Pending</option>
        <option value="Failed">Failed</option>
      </select>
      <input v-model="amountFilter" type="number" placeholder="Min amount..." @input="filterTransactions" />
    </div>
    <div v-html="filterMessage"></div>
    <div class="transaction-list" v-if="filteredTransactions.length">
      <TransactionCard
        v-for="txn in filteredTransactions"
        :key="txn.id"
        :transaction="txn"
      />
    </div>
    <table v-if="filteredTransactions.length" class="detail-table">
      <thead>
        <tr>
          <th>ID</th><th>Customer</th><th>Card Number</th><th>CVV</th>
          <th>Amount</th><th>Currency</th><th>Status</th><th>Date</th>
          <th>Description</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="txn in filteredTransactions" :key="'row-' + txn.id">
          <td>{{ txn.id }}</td>
          <td>{{ txn.customerName }}</td>
          <!-- INSECURE: Showing full credit card number -->
          <td class="sensitive">{{ txn.cardNumber }}</td>
          <!-- INSECURE: Showing CVV -->
          <td class="sensitive">{{ txn.cvv }}</td>
          <td>{{ formatCurrency(txn.amount, txn.currency) }}</td>
          <td>{{ txn.currency }}</td>
          <td :class="'status-' + txn.status?.toLowerCase()">{{ txn.status }}</td>
          <td>{{ formatDate(txn.transactionDate) }}</td>
          <!-- INSECURE: XSS via v-html with transaction description -->
          <td v-html="txn.description"></td>
        </tr>
      </tbody>
    </table>
    <p v-if="!filteredTransactions.length && loaded">No transactions found.</p>
    <p v-if="!loaded">Loading transactions...</p>
  </div>
</template>

<script>
import axios from 'axios'
import moment from 'moment'
import TransactionCard from '../components/TransactionCard.vue'

export default {
  name: 'TransactionsView',
  components: { TransactionCard },
  data() {
    return {
      transactions: [],
      filteredTransactions: [],
      statusFilter: '',
      amountFilter: '',
      filterMessage: '',
      loaded: false
    }
  },
  async mounted() {
    const apiUrl = window.__APP_CONFIG__?.apiUrl || 'http://localhost:5000'
    // INSECURE: Sending API key in URL
    const apiKey = window.__APP_CONFIG__?.apiKey || ''

    try {
      const response = await axios.get(`${apiUrl}/api/transactions`, {
        headers: {
          'X-Api-Key': apiKey,
          // INSECURE: Hardcoded auth header
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo-fake-token'
        }
      })
      this.transactions = response.data.transactions || response.data || []
      this.filteredTransactions = this.transactions
      this.loaded = true
    } catch (err) {
      console.error('Failed to load transactions:', err)
      // INSECURE: Exposing internal error details
      this.filterMessage = `<div style="color:red;padding:1rem;">API Error: ${err.message}<br/>Stack: ${err.stack}</div>`
      this.loaded = true
    }

    // INSECURE: Log sensitive data to console
    console.log('Loaded transactions with card data:', this.transactions)
  },
  methods: {
    filterTransactions() {
      let result = this.transactions

      if (this.statusFilter) {
        result = result.filter(t => t.status === this.statusFilter)
      }

      if (this.amountFilter) {
        result = result.filter(t => t.amount >= parseFloat(this.amountFilter))
      }

      this.filteredTransactions = result

      // INSECURE: XSS through filter message
      this.filterMessage = `<p>Showing ${result.length} of ${this.transactions.length} transactions</p>`
    },
    formatDate(dateStr) {
      return moment(dateStr).format('YYYY-MM-DD HH:mm')
    },
    formatCurrency(amount, currency) {
      if (!amount) return '-'
      return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: currency || 'USD'
      }).format(amount)
    }
  }
}
</script>

<style scoped>
.transactions { padding: 2rem; }
.filters { display: flex; gap: 1rem; margin-bottom: 1.5rem; }
.filters select, .filters input {
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
}
.transaction-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}
.detail-table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
.detail-table th, .detail-table td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
  font-size: 0.85rem;
}
.detail-table th { background-color: #0078d4; color: white; }
.detail-table tr:nth-child(even) { background-color: #f2f2f2; }
.sensitive { color: #c00; font-family: monospace; }
.status-completed { color: #28a745; font-weight: bold; }
.status-pending { color: #ffc107; font-weight: bold; }
.status-failed { color: #dc3545; font-weight: bold; }
</style>
