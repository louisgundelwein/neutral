FROM node:22-slim AS builder
WORKDIR /usr/src/app

# Copy package files
COPY package.json package-lock.json* ./
RUN npm ci

# Copy source code
COPY . .

# Build Quartz4 (creates public/ directory)
RUN npx quartz build

# Production stage with nginx
FROM nginx:alpine

# Copy built files to nginx
COPY --from=builder /usr/src/app/public /usr/share/nginx/html/

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 81

# Start nginx
CMD ["nginx", "-g", "daemon off;"]