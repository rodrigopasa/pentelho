FROM ubuntu:22.04

WORKDIR /app

# Definir variáveis de ambiente para evitar interações durante a instalação
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo
ENV NODE_ENV=production

# Instalar Node.js e outras dependências do sistema
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg2 \
    ca-certificates \
    lsb-release \
    git \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update \
    && apt-get install -y \
    nodejs \
    pdftk \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-venv \
    imagemagick \
    ghostscript \
    poppler-utils \
    tesseract-ocr \
    libtesseract-dev \
    ffmpeg \
    libmagickwand-dev \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurar o ImageMagick para permitir operações com PDF
RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml

# Criar ambiente virtual Python e instalar pdf2docx
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN /opt/venv/bin/pip install pdf2docx

# Criar diretório da aplicação
WORKDIR /app

# Criar setup-db.cjs - Versão CommonJS com queries reais
RUN echo 'const pg = require("pg"); \n\
\n\
// Configuração da conexão com o banco de dados \n\
const client = new pg.Client({ \n\
  connectionString: process.env.DATABASE_URL, \n\
}); \n\
\n\
async function setupDatabase() { \n\
  try { \n\
    console.log("Conectando ao banco de dados..."); \n\
    await client.connect(); \n\
    console.log("Conexão com o banco de dados estabelecida!"); \n\
\n\
    // Primeiro verificar quais tabelas já existem \n\
    const tableCheck = await client.query(`\n\
      SELECT table_name \n\
      FROM information_schema.tables \n\
      WHERE table_schema = '"'"'public'"'"' \n\
      ORDER BY table_name; \n\
    `); \n\
    \n\
    const existingTables = tableCheck.rows.map(row => row.table_name); \n\
    console.log("Tabelas existentes no banco de dados:", existingTables); \n\
\n\
    // Criar tabelas uma por uma com tratamento individual \n\
    console.log("Começando a criar ou verificar tabelas..."); \n\
\n\
    // Lista de queries para criar tabelas \n\
    const tables = [ \n\
      `CREATE TABLE IF NOT EXISTS users ( \n\
        id SERIAL PRIMARY KEY, \n\
        username VARCHAR(255) NOT NULL UNIQUE, \n\
        email VARCHAR(255) UNIQUE, \n\
        password VARCHAR(255) NOT NULL, \n\
        is_admin BOOLEAN DEFAULT FALSE, \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        is_blocked BOOLEAN DEFAULT FALSE, \n\
        profile_picture VARCHAR(255), \n\
        storage_used BIGINT DEFAULT 0, \n\
        storage_limit BIGINT DEFAULT 104857600 \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS session ( \n\
        sid VARCHAR(255) PRIMARY KEY, \n\
        sess JSON NOT NULL, \n\
        expire TIMESTAMP(6) NOT NULL \n\
      )`, \n\
      `CREATE INDEX IF NOT EXISTS IDX_session_expire ON session (expire)`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS categories ( \n\
        id SERIAL PRIMARY KEY, \n\
        name VARCHAR(255) NOT NULL, \n\
        slug VARCHAR(255) NOT NULL UNIQUE, \n\
        description TEXT, \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS pdfs ( \n\
        id SERIAL PRIMARY KEY, \n\
        title VARCHAR(255) NOT NULL, \n\
        slug VARCHAR(255) NOT NULL UNIQUE, \n\
        description TEXT, \n\
        file_path VARCHAR(255) NOT NULL, \n\
        thumbnail_path VARCHAR(255), \n\
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE, \n\
        category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL, \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        is_approved BOOLEAN DEFAULT FALSE, \n\
        file_hash VARCHAR(255), \n\
        view_count INTEGER DEFAULT 0, \n\
        download_count INTEGER DEFAULT 0, \n\
        meta_description TEXT, \n\
        meta_keywords TEXT \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS favorites ( \n\
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE, \n\
        pdf_id INTEGER REFERENCES pdfs(id) ON DELETE CASCADE, \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        PRIMARY KEY (user_id, pdf_id) \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS ratings ( \n\
        id SERIAL PRIMARY KEY, \n\
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE, \n\
        pdf_id INTEGER REFERENCES pdfs(id) ON DELETE CASCADE, \n\
        rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5), \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        likes INTEGER DEFAULT 0, \n\
        dislikes INTEGER DEFAULT 0, \n\
        UNIQUE(user_id, pdf_id) \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS comments ( \n\
        id SERIAL PRIMARY KEY, \n\
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE, \n\
        pdf_id INTEGER REFERENCES pdfs(id) ON DELETE CASCADE, \n\
        content TEXT NOT NULL, \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS dmca_requests ( \n\
        id SERIAL PRIMARY KEY, \n\
        pdf_id INTEGER REFERENCES pdfs(id) ON DELETE CASCADE, \n\
        requester_name VARCHAR(255) NOT NULL, \n\
        requester_email VARCHAR(255) NOT NULL, \n\
        reason TEXT NOT NULL, \n\
        evidence TEXT, \n\
        status VARCHAR(50) DEFAULT '"'"'pending'"'"', \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS slug_history ( \n\
        id SERIAL PRIMARY KEY, \n\
        pdf_id INTEGER REFERENCES pdfs(id) ON DELETE CASCADE, \n\
        old_slug VARCHAR(255) NOT NULL, \n\
        new_slug VARCHAR(255) NOT NULL, \n\
        changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS pdf_edits ( \n\
        id SERIAL PRIMARY KEY, \n\
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE, \n\
        title VARCHAR(255) NOT NULL, \n\
        status VARCHAR(50) DEFAULT '"'"'pending'"'"', \n\
        input_file_paths JSONB, \n\
        output_file_path VARCHAR(255), \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        completed_at TIMESTAMP \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS user_downloads ( \n\
        id SERIAL PRIMARY KEY, \n\
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE, \n\
        pdf_id INTEGER REFERENCES pdfs(id) ON DELETE CASCADE, \n\
        download_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        UNIQUE(user_id, pdf_id) \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS seo_settings ( \n\
        id SERIAL PRIMARY KEY, \n\
        site_title VARCHAR(255), \n\
        site_description TEXT, \n\
        meta_keywords TEXT, \n\
        google_analytics_id VARCHAR(255), \n\
        enable_sitemap BOOLEAN DEFAULT TRUE, \n\
        enable_robots BOOLEAN DEFAULT TRUE, \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS ad_settings ( \n\
        id SERIAL PRIMARY KEY, \n\
        ad_client VARCHAR(255), \n\
        ad_slot VARCHAR(255), \n\
        enable_ads BOOLEAN DEFAULT FALSE, \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS auth_settings ( \n\
        id SERIAL PRIMARY KEY, \n\
        google_client_id VARCHAR(255), \n\
        google_client_secret VARCHAR(255), \n\
        google_enabled BOOLEAN DEFAULT FALSE, \n\
        facebook_app_id VARCHAR(255), \n\
        facebook_app_secret VARCHAR(255), \n\
        facebook_enabled BOOLEAN DEFAULT FALSE, \n\
        github_client_id VARCHAR(255), \n\
        github_client_secret VARCHAR(255), \n\
        github_enabled BOOLEAN DEFAULT FALSE, \n\
        allow_registration BOOLEAN DEFAULT TRUE, \n\
        require_email_verification BOOLEAN DEFAULT FALSE, \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        google_callback_url VARCHAR(255) \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS site_settings ( \n\
        id SERIAL PRIMARY KEY, \n\
        site_name VARCHAR(255) DEFAULT '"'"'PDF Portal'"'"', \n\
        logo_path VARCHAR(255), \n\
        favicon_path VARCHAR(255), \n\
        primary_color VARCHAR(10) DEFAULT '"'"'#3B82F6'"'"', \n\
        enable_dark_mode BOOLEAN DEFAULT TRUE, \n\
        footer_text TEXT, \n\
        maintenance_mode BOOLEAN DEFAULT FALSE, \n\
        maintenance_message TEXT, \n\
        contact_email VARCHAR(255), \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS payment_settings ( \n\
        id SERIAL PRIMARY KEY, \n\
        mercadopago_public_key VARCHAR(255), \n\
        mercadopago_access_token VARCHAR(255), \n\
        mercadopago_enabled BOOLEAN DEFAULT FALSE, \n\
        currency VARCHAR(10) DEFAULT '"'"'BRL'"'"', \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS plans ( \n\
        id SERIAL PRIMARY KEY, \n\
        name VARCHAR(255) NOT NULL, \n\
        description TEXT, \n\
        price DECIMAL(10, 2) NOT NULL, \n\
        duration_days INTEGER NOT NULL, \n\
        features TEXT, \n\
        is_active BOOLEAN DEFAULT TRUE, \n\
        storage_limit BIGINT DEFAULT 104857600, \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS subscriptions ( \n\
        id SERIAL PRIMARY KEY, \n\
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE, \n\
        plan_id INTEGER REFERENCES plans(id) ON DELETE SET NULL, \n\
        start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        end_date TIMESTAMP, \n\
        status VARCHAR(50) DEFAULT '"'"'active'"'"', \n\
        payment_id VARCHAR(255), \n\
        payment_status VARCHAR(50), \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \n\
        external_reference VARCHAR(255) \n\
      )`, \n\
\n\
      `CREATE TABLE IF NOT EXISTS drizzle_migrations ( \n\
        id SERIAL PRIMARY KEY, \n\
        hash TEXT NOT NULL, \n\
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP \n\
      )` \n\
    ]; \n\
\n\
    // Executar as criações de tabelas sequencialmente \n\
    for (const tableQuery of tables) { \n\
      try { \n\
        await client.query(tableQuery); \n\
        console.log("Tabela verificada com sucesso."); \n\
      } catch (error) { \n\
        console.error("Erro ao verificar tabela:", error.message); \n\
      } \n\
    } \n\
\n\
    // Inserir dados iniciais nas tabelas de configuração \n\
    try { \n\
      const seoCount = await client.query(`SELECT COUNT(*) FROM seo_settings`); \n\
      if (parseInt(seoCount.rows[0].count) === 0) { \n\
        await client.query(` \n\
          INSERT INTO seo_settings (site_title, site_description) \n\
          VALUES ('"'"'PDF Portal - Seu repositório de documentos'"'"', '"'"'Um portal para gerenciar e compartilhar documentos PDF.'"'"') \n\
        `); \n\
        console.log("Dados iniciais inseridos na tabela seo_settings."); \n\
      } \n\
    } catch (err) { \n\
      console.error("Erro ao inserir dados iniciais na tabela seo_settings:", err.message); \n\
    } \n\
\n\
    try { \n\
      const siteCount = await client.query(`SELECT COUNT(*) FROM site_settings`); \n\
      if (parseInt(siteCount.rows[0].count) === 0) { \n\
        await client.query(` \n\
          INSERT INTO site_settings (site_name, primary_color) \n\
          VALUES ('"'"'PDF Portal'"'"', '"'"'#3B82F6'"'"') \n\
        `); \n\
        console.log("Dados iniciais inseridos na tabela site_settings."); \n\
      } \n\
    } catch (err) { \n\
      console.error("Erro ao inserir dados iniciais na tabela site_settings:", err.message); \n\
    } \n\
\n\
    console.log("Configuração do banco de dados concluída com sucesso!"); \n\
\n\
  } catch (err) { \n\
    console.error("Erro geral ao configurar o banco de dados:", err); \n\
  } finally { \n\
    await client.end(); \n\
    console.log("Conexão com o banco de dados fechada."); \n\
  } \n\
} \n\
\n\
setupDatabase(); \n' > /app/setup-db.cjs

# Criar entrypoint.sh
RUN echo '#!/bin/bash \n\
# Entrypoint simples para deploy com Nixpacks no Coolify \n\
\n\
set -e \n\
\n\
echo "🚀 Preparando ambiente de produção..." \n\
\n\
# Criar diretórios necessários \n\
mkdir -p uploads/pdfs uploads/images uploads/temp uploads/pdf-edits exports \n\
chmod -R 755 uploads exports \n\
\n\
# Configurar banco de dados usando nosso script Node.js em vez do Drizzle \n\
echo "🔄 Configurando banco de dados com Node.js..." \n\
node setup-db.cjs \n\
\n\
# Iniciar a aplicação \n\
echo "✅ Iniciando aplicação em modo de produção..." \n\
npm start \n' > /app/entrypoint.sh

# Ajustar permissões do script de entrada
RUN chmod +x /app/entrypoint.sh

# Copiar arquivos do projeto
COPY . .

# Temporariamente definir NODE_ENV como development para instalação de todas as dependências
ENV NODE_ENV=development

# Instalar TODAS as dependências, incluindo as de desenvolvimento
RUN npm ci

# Construir o projeto
RUN npm run build

# Manter NODE_ENV como development durante a execução
# (parece que sua aplicação está tentando usar o Vite em produção)
ENV NODE_ENV=development

# Criar diretórios persistentes para uploads
# Importante: Esses diretórios devem ser montados como volumes no ambiente de produção
RUN mkdir -p /app/uploads/pdfs \
    /app/uploads/images \
    /app/uploads/temp \
    /app/uploads/thumbnails \
    /app/uploads/pdf-edits \
    /app/exports \
    && chmod -R 755 /app/uploads /app/exports

# VOLUME instrui o Docker a tratar estes diretórios como persistentes
VOLUME ["/app/uploads/pdfs", "/app/uploads/thumbnails", "/app/uploads/pdf-edits", "/app/exports"]

# Porta a ser exposta
EXPOSE 5000

# Script de inicialização
ENTRYPOINT ["/app/entrypoint.sh"]
