import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// INSECURE: Storing API config in global variable accessible from console
window.__APP_CONFIG__ = {
  apiUrl: 'http://localhost:5000',
  apiKey: 'sk-demo-fake-api-key-1234567890abcdef',
  debug: true
}

const app = createApp(App)
app.use(router)
app.mount('#app')
