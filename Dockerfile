FROM node:22-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Debug: Zeige was vorhanden ist
RUN ls -la
RUN ls -la quartz/

# Build mit mehr Output
RUN npm run build 2>&1 | tee build.log || (cat build.log && exit 1)

# Debug: Zeige was gebaut wurde
RUN ls -la public/ || echo "public/ existiert nicht!"

FROM nginx:alpine
COPY --from=builder /app/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]