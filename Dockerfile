FROM node:22-slim AS builder
WORKDIR /usr/src/app

# Copy package files
COPY package.json package-lock.json* ./
RUN npm ci

# Copy source code
COPY . .

# Build Quartz (creates public/ directory)
RUN npx quartz build

# Production stage with nginx
FROM nginx:alpine

# Copy built files to nginx
COPY --from=builder /usr/src/app/public /usr/share/nginx/html/

# Create nginx config for Quartz (important!)
RUN echo 'server { \
  listen 80; \
  server_name _; \
  root /usr/share/nginx/html; \
  index index.html; \
  error_page 404 /404.html; \
  location / { \
  try_files $uri $uri.html $uri/ =404; \
  } \
  }' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]