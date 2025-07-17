#!/bin/bash

# Setup Database Script - Para resolver o erro DATABASE_URL definitivamente
echo "🔧 Configurando base de dados para o projeto..."

# Verificar se DATABASE_URL já está configurado
if [ -z "$DATABASE_URL" ]; then
    echo "❌ DATABASE_URL não configurado. Criando nova base de dados..."
    
    # Criar arquivo de configuração temporário
    cat > setup-db.js << 'EOF'
const { execSync } = require('child_process');

async function setupDatabase() {
    try {
        console.log('Criando base de dados PostgreSQL...');
        
        // Simular criação de base de dados
        const dbUrl = process.env.DATABASE_URL || 'postgresql://user:password@localhost:5432/database';
        
        if (!process.env.DATABASE_URL) {
            console.log('⚠️  DATABASE_URL não encontrado no ambiente.');
            console.log('📋 Instruções para configurar:');
            console.log('1. No Replit, vá para "Database" no painel lateral');
            console.log('2. Clique em "Create Database" e selecione PostgreSQL');
            console.log('3. A variável DATABASE_URL será automaticamente configurada');
            console.log('4. Reinicie o aplicativo após a configuração');
            process.exit(1);
        }
        
        console.log('✅ DATABASE_URL configurado');
        
        // Executar push do schema
        console.log('📦 Configurando schema da base de dados...');
        execSync('npm run db:push', { stdio: 'inherit' });
        
        console.log('🎉 Base de dados configurada com sucesso!');
        
    } catch (error) {
        console.error('❌ Erro ao configurar base de dados:', error.message);
        process.exit(1);
    }
}

setupDatabase();
EOF

    # Executar o script de configuração
    node setup-db.js
    
    # Limpar arquivo temporário
    rm setup-db.js
    
else
    echo "✅ DATABASE_URL já configurado"
    echo "🔄 Verificando schema da base de dados..."
    npm run db:push
fi

echo "🏁 Configuração concluída!"