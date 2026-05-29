#!/bin/bash

# Script de execução rápida

echo "🚀 Executando automação do LinkedIn..."
echo ""

# Ativa ambiente virtual se existir
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Verifica se .env existe
if [ ! -f .env ]; then
    echo "❌ Arquivo .env não encontrado!"
    echo "   Copie o .env.example e configure suas credenciais:"
    echo "   cp .env.example .env"
    exit 1
fi

# Carrega variáveis do .env
export $(cat .env | grep -v '^#' | xargs)

# Executa o teste
robot tests/linkedin_post.robot

echo ""
echo "✅ Execução finalizada!"
echo "📊 Veja os resultados em:"
echo "   - log.html"
echo "   - report.html"
echo ""
