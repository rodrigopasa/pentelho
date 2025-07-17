#!/usr/bin/env node

// Script para verificar configuração do ambiente
console.log('🔍 Verificando configuração do ambiente...\n');

// Verificar Node.js version
console.log(`📦 Node.js: ${process.version}`);

// Verificar variáveis de ambiente críticas
const requiredEnvs = ['DATABASE_URL'];
const optionalEnvs = ['PORT', 'NODE_ENV', 'PGDATABASE', 'PGUSER', 'PGHOST'];

console.log('\n🔐 Variáveis de ambiente:');

requiredEnvs.forEach(env => {
    const value = process.env[env];
    if (value) {
        console.log(`✅ ${env}: ${value.substring(0, 20)}...`);
    } else {
        console.log(`❌ ${env}: NÃO CONFIGURADO`);
    }
});

optionalEnvs.forEach(env => {
    const value = process.env[env];
    if (value) {
        console.log(`ℹ️  ${env}: ${value}`);
    }
});

// Verificar arquivos importantes
console.log('\n📁 Arquivos importantes:');
import fs from 'fs';
const importantFiles = [
    'package.json',
    'theme.json',
    'server/db.ts',
    'server/index.ts',
    'drizzle.config.ts',
    'shared/schema.ts'
];

importantFiles.forEach(file => {
    if (fs.existsSync(file)) {
        console.log(`✅ ${file}`);
    } else {
        console.log(`❌ ${file}: NÃO ENCONTRADO`);
    }
});

// Verificar se DATABASE_URL está configurado
if (!process.env.DATABASE_URL) {
    console.log('\n❌ ERRO: DATABASE_URL não está configurado!');
    console.log('\n📋 Para resolver:');
    console.log('1. No Replit: Database → Create Database → PostgreSQL');
    console.log('2. Em outros providers: Configure a variável DATABASE_URL');
    console.log('3. Execute: npm run db:push');
    console.log('4. Reinicie a aplicação');
    process.exit(1);
}

console.log('\n✅ Ambiente configurado corretamente!');
console.log('🚀 Pronto para executar a aplicação');