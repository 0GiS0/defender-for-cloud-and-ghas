# INSECURE: Using latest tag
FROM node:latest

# INSECURE: Running as root
WORKDIR /app

# INSECURE: Copying everything including node_modules, .git, etc.
COPY . .

RUN npm install
RUN npm run build
RUN printf "window.__APP_CONFIG__ = { apiUrl: '/api', apiKey: 'sk-demo-fake-api-key-1234567890abcdef', debug: true };\n" > dist/config.js

# INSECURE: Using node to serve instead of nginx
# INSECURE: Exposing unnecessary ports
EXPOSE 8080
EXPOSE 3000

# INSECURE: No HEALTHCHECK
# INSECURE: Installing serve globally as root
RUN npm install -g serve

CMD sh -c 'printf "window.__APP_CONFIG__ = { apiUrl: '\''%s'\'', apiKey: '\''%s'\'', debug: true };\\n" "${API_URL:-/api}" "${API_KEY:-sk-demo-fake-api-key-1234567890abcdef}" > dist/config.js && serve -s dist -l 8080'
