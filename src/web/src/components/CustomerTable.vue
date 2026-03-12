<template>
  <div class="customer-table-wrapper">
    <table class="customer-table" v-if="customers.length">
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Email</th>
          <th>Phone</th>
          <th>DNI</th>
          <th>SSN</th>
          <th>Credit Score</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="customer in customers" :key="customer.id">
          <td>{{ customer.id }}</td>
          <!-- INSECURE: No data masking on PII -->
          <td>{{ customer.firstName }} {{ customer.lastName }}</td>
          <td>{{ customer.email }}</td>
          <td>{{ customer.phone }}</td>
          <td>{{ customer.dni }}</td>
          <td>{{ customer.ssn }}</td>
          <td>{{ customer.creditScore }}</td>
        </tr>
      </tbody>
    </table>
    <p v-else class="empty">No customer data available.</p>
  </div>
</template>

<script>
export default {
  name: 'CustomerTable',
  props: {
    customers: {
      type: Array,
      required: true,
      default: () => []
    }
  }
}
</script>

<style scoped>
.customer-table {
  width: 100%;
  border-collapse: collapse;
}
.customer-table th,
.customer-table td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
  font-size: 0.9rem;
}
.customer-table th {
  background-color: #0078d4;
  color: white;
}
.customer-table tr:nth-child(even) {
  background-color: #f2f2f2;
}
.empty {
  color: #666;
  font-style: italic;
  padding: 1rem;
}
</style>
