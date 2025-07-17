# 🔧 Guia de Configuração da Base de Dados

## ❌ Erro Comum: DATABASE_URL must be set

Este erro acontece quando a variável de ambiente `DATABASE_URL` não está configurada no projeto.

### 🚀 Solução Rápida (Replit)

1. **Abra o painel lateral** do Replit
2. **Clique em "Database"** (ícone de base de dados)
3. **Selecione "PostgreSQL"**
4. **Clique em "Create Database"**
5. **Aguarde a criação** (pode demorar alguns minutos)
6. **Reinicie o aplicativo** clicando no botão "Run"

### 🔧 Solução Automática

Execute o script de configuração:

```bash
chmod +x scripts/setup-database.sh
./scripts/setup-database.sh
```

### 📋 Verificação Manual

Depois de configurar, verifique se funciona:

```bash
# 1. Verificar se DATABASE_URL existe
echo $DATABASE_URL

# 2. Configurar schema
npm run db:push

# 3. Iniciar aplicação
npm run dev
```

### 🐛 Troubleshooting

#### Se o erro persistir:

1. **Verifique as variáveis de ambiente:**
   ```bash
   env | grep DATABASE
   ```

2. **Recrie a base de dados:**
   - Vá para Database > Settings > Delete Database
   - Crie uma nova base de dados
   - Reinicie o aplicativo

3. **Verifique o arquivo server/db.ts:**
   - O erro vem da linha 6 deste arquivo
   - Certifique-se de que o código está correto

#### Se usar outro provedor (não Replit):

1. **Coolify/Docker:**
   ```bash
   # Adicionar variável de ambiente
   DATABASE_URL=postgresql://user:password@host:5432/database
   ```

2. **Railway:**
   - Vá para Variables
   - Adicione DATABASE_URL
   - Cole a string de conexão PostgreSQL

3. **Vercel/Netlify:**
   - Configure nas Environment Variables
   - Use PostgreSQL da Neon, PlanetScale, ou similar

### 📁 Arquivos de Configuração

#### .env (se necessário)
```
DATABASE_URL=postgresql://user:password@host:5432/database
```

#### package.json scripts
```json
{
  "scripts": {
    "db:push": "drizzle-kit push",
    "db:migrate": "drizzle-kit migrate",
    "setup": "./scripts/setup-database.sh"
  }
}
```

### ✅ Sucesso

Quando configurado corretamente, você verá:
```
Testing database connection...
Database connection successful!
Initializing database data...
Admin user creation completed.
Default categories creation completed.
Database initialization completed successfully.
```

### 🆘 Suporte

Se nada funcionar:
1. Verifique se o PostgreSQL está realmente ativo
2. Teste a conexão manualmente
3. Recrie todo o projeto se necessário
4. Contate o suporte do provedor (Replit, Coolify, etc.)

---

**Lembre-se:** Este erro é sempre relacionado à falta de configuração da base de dados, não ao código da aplicação.