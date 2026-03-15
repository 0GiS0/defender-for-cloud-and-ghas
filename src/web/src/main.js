import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// INSECURE: Storing API config in global variable accessible from console
window.__APP_CONFIG__ = {
  apiUrl: window.__APP_CONFIG__?.apiUrl || '/api',
  apiKey: window.__APP_CONFIG__?.apiKey || 'sk-demo-fake-api-key-1234567890abcdef',
  debug: window.__APP_CONFIG__?.debug ?? true
}

const app = createApp(App)
app.use(router)
app.mount('#app')
