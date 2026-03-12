# INSECURE: Using latest tag
FROM node:latest

# INSECURE: Running as root
WORKDIR /app

# INSECURE: Copying everything including node_modules, .git, etc.
COPY . .

RUN npm install
RUN npm run build

# INSECURE: Using node to serve instead of nginx
# INSECURE: Exposing unnecessary ports
EXPOSE 8080
EXPOSE 3000

# INSECURE: No HEALTHCHECK
# INSECURE: Installing serve globally as root
RUN npm install -g serve

CMD ["serve", "-s", "dist", "-l", "8080"]
