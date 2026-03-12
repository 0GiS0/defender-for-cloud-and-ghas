<template>
  <div id="app">
    <nav class="navbar">
      <div class="nav-brand">📊 Sensitive Data Portal</div>
      <div class="nav-links">
        <router-link to="/">Home</router-link>
        <router-link to="/customers">Customers</router-link>
        <router-link to="/transactions">Transactions</router-link>
      </div>
    </nav>
    <main class="content">
      <router-view />
    </main>
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background-color: #f0f2f5;
  color: #333;
}

.navbar {
  background-color: #0078d4;
  padding: 1rem 2rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.nav-brand {
  color: white;
  font-size: 1.4rem;
  font-weight: bold;
}

.nav-links {
  display: flex;
  gap: 1.5rem;
}

.nav-links a {
  color: rgba(255, 255, 255, 0.85);
  text-decoration: none;
  font-weight: 500;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.nav-links a:hover,
.nav-links a.router-link-active {
  background-color: rgba(255, 255, 255, 0.15);
  color: white;
}

.content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
</style>
