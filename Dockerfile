# Use Node.js 20 LTS
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# ADICIONE ESTA LINHA para instalar as dependências para o pacote "canvas"
RUN apk add --no-cache build-base g++ cairo-dev jpeg-dev pango-dev giflib-dev

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Expose port
EXPOSE 5000

# Start the application
CMD ["npm", "start"]
