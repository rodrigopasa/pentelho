# Use Node.js 20 LTS
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# ADICIONE ESTA LINHA para instalar as dependências para o pacote "canvas"
RUN apk add --no-cache build-base g++ cairo-dev jpeg-dev pango-dev giflib-dev

# Instala TODAS as dependências (incluindo as de desenvolvimento como "vite")
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Expose port
EXPOSE 5000

# Comando de diagnóstico: Imprime as variáveis de ambiente e então tenta iniciar
CMD ["sh", "-c", "echo '--- Variáveis de Ambiente Disponíveis ---' && printenv && echo '--- Fim das Variáveis ---' && echo '--- Iniciando Aplicação ---' && npm run db:push && npm start"]
