<template>
  <div class="txn-card" :class="'border-' + (transaction.status?.toLowerCase() || 'default')">
    <div class="txn-header">
      <span class="txn-id">#{{ transaction.id }}</span>
      <span class="txn-status" :class="'status-' + (transaction.status?.toLowerCase() || 'default')">
        {{ transaction.status }}
      </span>
    </div>
    <div class="txn-body">
      <p class="txn-customer">{{ transaction.customerName }}</p>
      <p class="txn-amount">{{ formatAmount(transaction.amount, transaction.currency) }}</p>
      <!-- INSECURE: Displaying full card number without masking -->
      <p class="txn-card-number">💳 {{ transaction.cardNumber }}</p>
      <!-- INSECURE: Displaying CVV -->
      <p class="txn-cvv">CVV: {{ transaction.cvv }}</p>
      <p class="txn-date">{{ transaction.transactionDate }}</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TransactionCard',
  props: {
    transaction: {
      type: Object,
      required: true
    }
  },
  methods: {
    formatAmount(amount, currency) {
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
.txn-card {
  background: white;
  border-radius: 8px;
  padding: 1rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
  border-left: 4px solid #ccc;
}
.border-completed { border-left-color: #28a745; }
.border-pending { border-left-color: #ffc107; }
.border-failed { border-left-color: #dc3545; }

.txn-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}
.txn-id { font-weight: bold; color: #555; }
.status-completed { color: #28a745; font-weight: bold; }
.status-pending { color: #ffc107; font-weight: bold; }
.status-failed { color: #dc3545; font-weight: bold; }

.txn-body p { margin: 0.25rem 0; }
.txn-customer { font-weight: 600; }
.txn-amount { font-size: 1.3rem; color: #0078d4; }
.txn-card-number { font-family: monospace; color: #c00; }
.txn-cvv { font-family: monospace; color: #c00; font-size: 0.85rem; }
.txn-date { font-size: 0.8rem; color: #888; }
</style>
